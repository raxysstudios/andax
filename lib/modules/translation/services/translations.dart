import 'package:andax/models/story.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/store.dart';

Future<List<StoryInfo>> getAllTranslations(String storyId) async {
  final query = algolia.index('stories').filters('storyID:$storyId');
  final snapshot = await query.getObjects();
  return storiesFromSnapshot(snapshot);
}
