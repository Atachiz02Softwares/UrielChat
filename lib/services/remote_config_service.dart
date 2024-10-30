import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../utils/strings.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  String get payStackPublicKey => _remoteConfig.getString('payStackPublicKey');

  String get payStackSecretKey => _remoteConfig.getString('payStackSecretKey');

  String get freeModel => _remoteConfig.getString('${Strings.f}Model');

  String get paidModel => _remoteConfig.getString('paidModel');

  String get freeAPIKey => _remoteConfig.getString('${Strings.f}APIKey');

  String get paidAPIKey => _remoteConfig.getString('paidAPIKey');

  String get stabilityAPIKey => _remoteConfig.getString('stabilityAPIKey');

  int get free => _remoteConfig.getInt(Strings.f);

  int get regular => _remoteConfig.getInt(Strings.r);

  double get regularMoney => _remoteConfig.getDouble('${Strings.r}Money');

  int get premium => _remoteConfig.getInt(Strings.p);

  double get premiumMoney => _remoteConfig.getDouble('${Strings.p}Money');

  int get platinum => _remoteConfig.getInt(Strings.pl);

  double get platinumMoney => _remoteConfig.getDouble('${Strings.pl}Money');

  // {"plans": ["premium", "platinum"]}
  List<String> get mediaPlans {
    final String jsonString = _remoteConfig.getString('mediaPlans');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> plansList = jsonMap['plans'];
    return plansList.cast<String>();
  }
}
