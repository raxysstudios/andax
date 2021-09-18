import algoliasearch from "algoliasearch";
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";

const index = algoliasearch(
    functions.config().algolia.app,
    functions.config().algolia.key
)
    .initIndex("scenarios");

type scenarioRecord = {
    scenarioId: string;
    translationId: string;
    language: string;
    title: string,
    description:string,
};

export const indexScenarios = functions
    .region("europe-central2")
    .firestore.document(
        "scenarios/{scenarioId}/translations/{translationId}/assets/scenario"
    )
    .onWrite(async (change, context) => {
      const translationId = context.params.translationId;
      const scenarioId = context.params.scenarioId;
      if (change.before.exists) {
        await index.deleteBy({
          filters: "translationId:" + translationId,
        });
      }
      if (change.after.exists) {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const asset = change.after.data()!;
        const language = await firestore()
            .doc(`scenarios/${scenarioId}/translations/${translationId}`)
            .get()
            .then((doc) => doc.data()?.language);
        if (language) {
          await index.saveObject(
            {
              scenarioId,
              translationId,
              language,
              title: asset.title,
              description: asset.description,
            } as scenarioRecord,
            {autoGenerateObjectIDIfNotExist: true}
          );
        }
      }
    });
