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

type storyRecord = {
  storyID: string,
  storyAuthorID:string,
  translationID: string,
  translationAuthorID: string,
  language: string,
  title: string,
  description: string,
};

export const indexStories = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}/assets/story"
    )
    .onWrite(async (change, context) => {
      const translationID = context.params.translationID;
      const storyID = context.params.storyID;
      if (change.before.exists) {
        await index.deleteBy({
          filters: "translationID:" + translationID,
        });
      }
      if (change.after.exists) {
        const {title, description, tags} = change.after.data()!;
        const story = await db
            .doc(`stories/${storyID}`)
            .get()
            .then((doc) => doc.data()!);
        const translation = await db
            .doc(`stories/${storyID}/translations/${translationID}`)
            .get()
            .then((doc) => doc.data()!);
        await index.partialUpdateObject(
        {
          storyID,
          storyAuthorID: story.metaData.authorId,
          translationID,
          translationAuthorID: translation.metaData.authorId,
          language: translation.language,
          title,
          description,
          tags,
        } as storyRecord,
        {createIfNotExists: true}
        );
      }
    });

export const updateStoryMeta = functions
    .region("europe-central2")
    .firestore.document(
        "stories/{storyID}/translations/{translationID}"
    )
    .onWrite(async (change, context) => {
      if (change.after.exists) {
        const meta = change.after.data()?.metaData;
        const likes = meta.likes ?? 0;
        const views = meta.views ?? 0;

        if (change.before.exists) {
          const {_likes, _views} = change.before.data()?.metaData;
          if (_likes === likes && _views === views) return;
        }

        const objectID = await index.search("", {
          filters: "translationID:" + context.params.translationID,
          hitsPerPage: 1,
        }).then((r) => r.hits[0]?.objectID);
        if (!objectID) return;

        await index.partialUpdateObject({objectID, likes, views});
      }
    });

export const indexTrendingStories = functions
    .region("europe-central2")
    .pubsub.schedule("every 72 hours")
    .onRun(async () => {
      await index.browseObjects({
        query: "",
        attributesToRetrieve: [
          "storyID",
          "translationID",
        ],
        batch: async (batch) => {
          for (const hit of batch) {
            const {storyID, translationID, objectID} = (hit as never);
            const doc = db
                .doc(`stories/${storyID}/translations/${translationID}`);
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
      const doc = db
          .doc(`stories/${storyID}/translations/${translationID}`);
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
