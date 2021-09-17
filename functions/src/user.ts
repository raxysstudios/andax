import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";

export const addUser = functions
    .region("europe-central2")
    .auth.user()
    .onCreate((user) =>
      firebase.firestore()
          .doc("users/" + user.uid)
          .set({
            displayName: user.displayName,
            photoURL: user.photoURL,
          })
    );

export const deleteUser = functions.region("europe-central2")
    .auth.user()
    .onDelete((user) =>
      firebase.firestore()
          .doc("users/" + user.uid)
          .delete()
    );
