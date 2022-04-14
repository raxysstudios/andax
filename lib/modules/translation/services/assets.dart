import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, String>> getPendingAssets(StoryInfo info, String id) async {
  final q = await FirebaseFirestore.instance
      .collection(
        'stories/${info.storyID}/translations/${info.translationID}/pending',
      )
      .where('target', isEqualTo: id)
      .get();
  return {for (final d in q.docs) d.id: d.data()['text'] as String? ?? ''};
}
