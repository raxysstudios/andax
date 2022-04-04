import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';

// For some reason, the client ID for iOS is different than for Web and Android
// The `kIsWeb` has to be the first check as `Platform` is not available in web
final kGoogleClientId = kIsWeb || Platform.isAndroid
    ? '803265650064-n8euv0sb8rcd1vrl8q49nj8p7e9qnr64.apps.googleusercontent.com'
    : '803265650064-as3usri2iu8eba80tgdmrklvr2tvmtm6.apps.googleusercontent.com';

final List<ProviderConfiguration> providerConfigs = [
  const EmailProviderConfiguration(),
  GoogleProviderConfiguration(clientId: kGoogleClientId),
  const AppleProviderConfiguration(),
];
