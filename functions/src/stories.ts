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
  storyID: string;
  translationID: string;
  language: string;
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
        await index.saveObject(
        {
          storyID,
          storyAuthorID: story.metaData.authorId,
          translationID,
          translationAuthorID: translation.metaData.authorId,
          language: translation.language,
          title,
          description,
          tags,
          likes: translation.metaData.likes,
        } as storyRecord,
        {autoGenerateObjectIDIfNotExist: true}
        );
      }
    });

// TODO
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
      const srch = await index.search("", {
        facetFilters: ["storyID:" + storyID, "translationID:" + translationID],
        attributesToRetrieve: ["objectID", "likes"],
        hitsPerPage: 1,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      }).then((h) =>h.hits[0] as Record<string, any>);
      let value: firestore.FieldValue | undefined;
      if (!change.before.exists && change.after.exists) {
        value = firestore.FieldValue.increment(1);
        srch.likes += 1;
      } else if (change.before.exists && !change.after.exists) {
        value = firestore.FieldValue.increment(-1);
        srch.likes -= 1;
      }
      if (value) {
        await doc.update({"metaData.likes": value});
        await db.doc("users/" + context.params.userID)
            .update({"likes": value});
        await index.partialUpdateObject(srch);
      }
    });
