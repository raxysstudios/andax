import 'package:andax/firebase_options.dart';
import 'package:flutterfire_ui/auth.dart';

final List<ProviderConfiguration> providerConfigs = [
  const EmailProviderConfiguration(),
  GoogleProviderConfiguration(
      clientId: DefaultFirebaseOptions.currentPlatform.appId),
  const AppleProviderConfiguration(),
];
