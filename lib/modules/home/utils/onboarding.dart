import 'package:andax/models/story.dart';
import 'package:andax/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StoryInfo?> needsOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;
  if (onboarded) return null;

  final obj = await algolia
      .index('stories')
      .getObjectsByIds(['STXZlBw4mA3culnp0tYi'])
      .then((s) => s.map(StoryInfo.fromAlgoliaHit))
      .catchError((dynamic e) => <StoryInfo>[]);
  return obj.isEmpty ? null : obj.first;
}
