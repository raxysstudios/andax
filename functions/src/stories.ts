/* eslint-disable @typescript-eslint/no-non-null-assertion */
import algoliasearch from "algoliasearch";
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";
import type {
  CollectionReference,
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";

const index = algoliasearch(
    functions.config().algolia.app,
    functions.config().algolia.key
)
    .initIndex("stories");

const db = firestore();

type StoryRecord = {
  objectID: string,
  storyID: string,
  storyAuthorID:string,
  translationID: string,
  translationAuthorID: string,
  language: string,
  title: string,
  imageUrl:string,
  description: string,
  tags: string[],
  lastUpdateAt?: number,
};

type MetaData = {
  authorID: string,
  contributorsIDs?: string[],
  lastUpdateAt?: Timestamp,
  imageUrl?:string,
  likes?: number,
  views?: number,
  lastIndexedViews?: number,
  status?: "public" | "unlisted" | "private" | "pending"
};

type StoryDoc = {
  actors: Array<{avatarUrl: string; id: string}>;
  coverUrl: string;
  metaData: {
    authorId: string,
    lastUpdateAt?: Timestamp,
  };
  startNodeId: string|null;
}

type TranslationDoc = {
  language: string;
  metaData: {
    authorId: string;
    lastUpdateAt?: Timestamp;
    likes: number;
    views: number;
    lastIndexedViews: number | null;
  };
};

function storyDoc(storyID: string): DocumentReference<StoryDoc>;
function storyDoc(storyID: string, translationID: string):
  DocumentReference<TranslationDoc>;
/**
 * Returns document reference by story and trabslation id.
 * @param {string} storyID The ID of the story document.
 * @param {string} translationID The ID of the translation document.
 * @return {object} The document reference.
**/
function storyDoc(storyID: string, translationID?: string) {
  let path = "stories/" + storyID;
  if (translationID) {
    path += "/translations/" + translationID;
  }
  return db.doc(path);
}

/**
 * Returns document reference by story and trabslation id.
 * @param {object} collection Reference to translation assets.
 * @param {string} assetID The ID of the asset document.
 * @return {Promise<string>} The text content of the asset.
**/
async function getAssetText(
    collection: CollectionReference,
    assetID: string
): Promise<string> {
  const data = await collection
      .doc(assetID)
      .get()
      .then((doc) => doc.data());
  return data == null ? "" : data["text"] as string;
}


export const indexStories = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}"
    )
    .onWrite(async (change, context) => {
      const translationID = context.params.translationID;
      const storyID = context.params.storyID;
      if (!change.after.exists) {
        await index.deleteObject(translationID);
        return;
      }
      const assets = change.after.ref.collection("assets");
      const title = await getAssetText(assets, "title");
      const description = await getAssetText(assets, "description");
      const tags = await getAssetText(assets, "tags");

      const story = await storyDoc(storyID)
          .get()
          .then((doc) => doc.data()!);
      const translation = await storyDoc(storyID, translationID)
          .get()
          .then((doc) => doc.data()!);

      const entry: StoryRecord = {
        objectID: translationID,
        storyID,
        storyAuthorID: story.metaData.authorId,
        translationID,
        translationAuthorID: translation.metaData.authorId,
        language: translation.language,
        title,
        description,
        tags: tags.split(" ").filter((t) => t),
        imageUrl: story.coverUrl,
      };

      if (change.before.exists) {
        await index.partialUpdateObject(
            entry,
            {createIfNotExists: true}
        );
      } else {
        await index.saveObject(entry);
      }
    });

export const updateStoryMeta = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}"
    )
    .onWrite(async (change, context) => {
      if (!change.after.exists) return;
      const meta = change.after.data()?.metaData as MetaData;
      await index.partialUpdateObject({
        objectID: context.params.translationID,
        likes: meta.likes ?? 0,
        views: meta.views ?? 0,
        lastUpdateAt: meta.lastUpdateAt?.toMillis(),
        imageUrl: meta.imageUrl,
      });
    });

export const indexTrendingStories = functions
    .region("europe-central2")
    .pubsub.schedule("every 72 hours")
    .onRun(async () => {
      await index.browseObjects<StoryRecord>({
        query: "",
        attributesToRetrieve: ["storyID"],
        batch: async (batch) => {
          for (const hit of batch) {
            const {storyID, objectID} = hit;
            const doc = storyDoc(storyID, objectID);
            const meta = await doc.get().then((r) => r.data()!.metaData);
            const trending = (meta.views ?? 0) - (meta.lastIndexedViews ?? 0);
            await doc.update({"metaData.lastIndexedViews": meta.views ?? 0});
            await index.partialUpdateObject({objectID, trending});
          }
        },
      });
    });

export const indexRandomExploration = functions
    .region("europe-central2")
    .pubsub.schedule("every 24 hours")
    .onRun(async () => {
      await index.browseObjects<StoryRecord>({
        query: "",
        attributesToRetrieve: [],
        batch: async (batch) => {
          for (const hit of batch) {
            await index.partialUpdateObject({
              objectID: hit.objectID,
              explore: Math.random(),
            });
          }
        },
      });
    });

export const countLikes = functions
    .region("europe-central2")
    .firestore.document(
        "users/{userID}/likes/{likeID}"
    )
    .onWrite(async (change, context) => {
      const {storyID, translationID} =
      (change.before.data() ?? change.after.data())!;
      const doc = storyDoc(storyID, translationID);
      let value: firestore.FieldValue | undefined;
      if (!change.before.exists && change.after.exists) {
        value = firestore.FieldValue.increment(1);
      } else if (change.before.exists && !change.after.exists) {
        value = firestore.FieldValue.increment(-1);
      }
      if (value) {
        await doc.update({"metaData.likes": value});
        await db.doc("users/" + context.params.userID)
            .update({"likes": value});
      }
    });

export const deleteStory = functions
    .region("europe-central2")
    .https.onCall(async (storyId: string, context) => {
      const storyRef = storyDoc(storyId);
      const story = await storyRef.get();
      if (context.auth?.uid !== story.data()?.metaData.authorId) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Only the author can delete the story"
        );
      }
      const translations = await storyRef.collection("translations").get();
      for (const translation of translations.docs) {
        const assets = await translation.ref.collection("assets").get();
        await Promise.all(assets.docs.map((asset) => asset.ref.delete()));
        await translation.ref.delete();
      }
      const likes = await db.collectionGroup("likes")
          .where("storyID", "==", storyId).get();
      await Promise.all(likes.docs.map((like) => like.ref.delete()));

      await storyRef.delete();
    });
