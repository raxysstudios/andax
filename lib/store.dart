import 'package:algolia/algolia.dart';
import 'package:andax/models/settings.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

final settings = Settings(targetLanguage: 'english', nativeLanguage: 'russian');

late final Algolia algolia;

Future<void> initStore() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  algolia = const Algolia.init(
    applicationId: '4NXJPAZXKE',
    apiKey: 'aef86c663aa0f382553f4375013c2de2',
  );
}
