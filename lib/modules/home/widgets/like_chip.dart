import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';

class LikeChip extends StatefulWidget {
  const LikeChip(
    this.info, {
    Key? key,
  }) : super(key: key);

  final StoryInfo info;

  @override
  _LikeChipState createState() => _LikeChipState();
}

class _LikeChipState extends State<LikeChip> {
  User? get user => FirebaseAuth.instance.currentUser;
  DocumentReference<Map<String, dynamic>>? _likeDoc;

  var initialLike = false;
  var liked = false;

  @override
  void initState() {
    super.initState();
    updateLikedState().then(
      (l) => setState(() {
        initialLike = l;
        liked = l;
      }),
    );
  }

  Future<bool> updateLikedState() async {
    if (user == null) return false;
    _likeDoc = FirebaseFirestore.instance.doc(
      'users/${user!.uid}/likes/${widget.info.translationID}',
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
          'storyID': widget.info.storyID,
          'translationID': widget.info.translationID,
          'date': Timestamp.now(),
        },
      );
    } else {
      await doc.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final likes = widget.info.likes + (liked ? 1 : 0) - (initialLike ? 1 : 0);
    return InputChip(
      avatar: Icon(
        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      ),
      elevation: liked ? 3 : 0,
      label: Text(likes.toString()),
      onPressed: () => ensureSignIn(
        context,
        () => setState(() {
          liked = !liked;
          toggleLike(liked);
        }),
        'Sign in to like this story',
      ),
    );
  }
}
