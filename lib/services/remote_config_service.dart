import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  String get payStackPublicKey => _remoteConfig.getString('payStackPublicKey');

  String get payStackSecretKey => _remoteConfig.getString('payStackSecretKey');

  String get freeModel => _remoteConfig.getString('freeModel');

  String get paidModel => _remoteConfig.getString('paidModel');

  String get freeAPIKey => _remoteConfig.getString('freeAPIKey');

  String get paidAPIKey => _remoteConfig.getString('paidAPIKey');

  int get free => _remoteConfig.getInt('free');

  int get regular => _remoteConfig.getInt('regular');

  double get regularMoney => _remoteConfig.getDouble('regularMoney');

  int get premium => _remoteConfig.getInt('premium');

  double get premiumMoney => _remoteConfig.getDouble('premiumMoney');

  int get platinum => _remoteConfig.getInt('platinum');

  double get platinumMoney => _remoteConfig.getDouble('platinumMoney');
}
