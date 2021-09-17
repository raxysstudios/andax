import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";

export const addUser = functions.auth.user().onCreate((user) =>
  firebase.firestore()
      .doc("users/" + user.uid)
      .set({
        displayName: user.displayName,
        photoURL: user.photoURL,
      })
);

export const deleteUser = functions.auth.user().onDelete((user) =>
  firebase.firestore()
      .doc("users/" + user.uid)
      .delete()
);
