import 'package:flutterfire_ui/auth.dart';

const kGoogleClientId =
    '803265650064-as3usri2iu8eba80tgdmrklvr2tvmtm6.apps.googleusercontent.com';

const List<ProviderConfiguration> providerConfigs = [
  EmailProviderConfiguration(),
  GoogleProviderConfiguration(clientId: kGoogleClientId),
  AppleProviderConfiguration(),
];
