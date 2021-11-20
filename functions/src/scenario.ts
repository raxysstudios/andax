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
    description:string,
};

export const indexstorys = functions
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
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const {title, description} = change.after.data()!;
        const language = await firestore()
            .doc(`stories/${storyID}/translations/${translationID}`)
            .get()
            .then((doc) => doc.data()?.language);
        await index.saveObject(
            {
              storyID,
              translationID,
              language,
              title,
              description,
            } as storyRecord,
            {autoGenerateObjectIDIfNotExist: true}
        );
      }
    });
