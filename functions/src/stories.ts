/* eslint-disable @typescript-eslint/no-non-null-assertion */
import algoliasearch from "algoliasearch";
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";

const index = algoliasearch(
    functions.config().algolia.app,
    functions.config().algolia.key
)
    .initIndex("stories");

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
        const story = await firestore()
            .doc(`stories/${storyID}`)
            .get()
            .then((doc) => doc.data()!);
        const translation = await firestore()
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
