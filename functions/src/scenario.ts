import algoliasearch from "algoliasearch";
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";

const index = algoliasearch(
    functions.config().algolia.app,
    functions.config().algolia.key
)
    .initIndex("scenarios");

type scenarioRecord = {
    scenarioID: string;
    translationID: string;
    language: string;
    title: string,
    description:string,
};

export const indexScenarios = functions
    .region("europe-central2")
    .firestore.document(
        "scenarios/{scenarioID}/translations/{translationID}/assets/scenario"
    )
    .onWrite(async (change, context) => {
      const translationID = context.params.translationId;
      const scenarioID = context.params.scenarioId;
      if (change.before.exists) {
        await index.deleteBy({
          filters: "translationID:" + translationID,
        });
      }
      if (change.after.exists) {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const asset = change.after.data()!;
        const language = await firestore()
            .doc(`scenarios/${scenarioID}/translations/${translationID}`)
            .get()
            .then((doc) => doc.data()?.language);
        if (language) {
          await index.saveObject(
            {
              scenarioID,
              translationID,
              language,
              title: asset.title,
              description: asset.description,
            } as scenarioRecord,
            {autoGenerateObjectIDIfNotExist: true}
          );
        }
      }
    });
