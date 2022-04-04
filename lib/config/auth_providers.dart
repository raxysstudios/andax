import 'package:flutterfire_ui/auth.dart';

const kGoogleClientId =
    '803265650064-n8euv0sb8rcd1vrl8q49nj8p7e9qnr64.apps.googleusercontent.com';

const List<ProviderConfiguration> providerConfigs = [
  EmailProviderConfiguration(),
  GoogleProviderConfiguration(clientId: kGoogleClientId),
  AppleProviderConfiguration(),
];
