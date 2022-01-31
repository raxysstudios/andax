/* eslint-disable require-jsdoc */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
import algoliasearch from "algoliasearch";
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";

const index = algoliasearch(
    functions.config().algolia.app,
    functions.config().algolia.key
)
    .initIndex("stories");

const db = firestore();

type StoryRecord = {
  storyID: string,
  storyAuthorID:string,
  translationID: string,
  translationAuthorID: string,
  language: string,
  title: string,
  description?: string,
  tags?: string[],
  lastUpdateAt?: Date,
};

function storyDoc(storyID: string, translationID?: string):
  firestore.DocumentReference<firestore.DocumentData> {
  let path = "stories/" + storyID;
  if (translationID) {
    path += "/translations/" + translationID;
  }
  return db.doc(path);
}

export const indexStories = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}/assets/story"
    )
    .onWrite(async (change, context) => {
      if (!change.after.exists) return;
      const translationID = context.params.translationID;
      const storyID = context.params.storyID;
      const {title, description, tags} = change.after.data()!;
      const story = await storyDoc(storyID)
          .get()
          .then((doc) => doc.data()!);
      const translation = await storyDoc(storyID, translationID)
          .get()
          .then((doc) => doc.data()!);

      const entry: StoryRecord = {
        storyID,
        storyAuthorID: story.metaData.authorId,
        translationID,
        translationAuthorID: translation.metaData.authorId,
        language: translation.language,
        title,
        description,
        tags,
      };
      if (change.before.exists) {
        await index.partialUpdateObject(
            {objectID: translationID, ...entry},
            {createIfNotExists: true}
        );
      } else {
        await index.saveObject(
            entry,
            {autoGenerateObjectIDIfNotExist: true}
        );
      }
    });

export const trackStoryUpdateTime = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}/assets/{assetID}"
    )
    .onWrite(async (change, context) => {
      if (!change.after.exists) return;
      await storyDoc(context.params.storyID, context.params.translationID)
          .update({
            "metaData.lastUpdateAt": firestore.FieldValue.serverTimestamp(),
          });
    });

export const updateStoryMeta = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}"
    )
    .onWrite(async (change, context) => {
      if (change.after.exists) {
        const meta = change.after.data()?.metaData;
        await index.partialUpdateObject({
          objectID: context.params.translationID,
          likes: meta.likes ?? 0,
          views: meta.views ?? 0,
          lastUpdateAt: meta.lastUpdateAt,
        });
      }
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
