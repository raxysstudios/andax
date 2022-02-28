import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final StoryInfo _info;
  DocumentReference<Map<String, dynamic>>? _likeDoc;

  LikeService(this._info);

  Future<bool?> updateLikedState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    _likeDoc = FirebaseFirestore.instance.doc(
      'users/${user.uid}/likes/${_info.translationID}',
    );
    final doc = await _likeDoc!.get();
    return doc.exists;
  }

  Future<void> toggleLike(bool? liked) async {
    final doc = _likeDoc;
    if (liked == null || doc == null) return;
    if (liked) {
      await doc.set(
        <String, dynamic>{
          'storyID': _info.storyID,
          'translationID': _info.translationID,
          'date': Timestamp.now(),
        },
      );
    } else {
      await doc.delete();
    }
  }
}
