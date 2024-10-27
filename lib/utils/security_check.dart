import 'dart:io' show Platform, File;

import 'package:device_info_plus/device_info_plus.dart';

Future<bool> isDeviceRooted() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return await _isAndroidRooted(androidInfo);
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return await _isIOSJailbroken(iosInfo);
  } else {
    return false;
  }
}

Future<bool> _isAndroidRooted(AndroidDeviceInfo androidInfo) async {
  // if (!androidInfo.isPhysicalDevice) return true;

  final rootIndicators = [
    '/system/app/Superuser.apk',
    '/sbin/su',
    '/system/bin/su',
    '/system/xbin/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/su',
    '/system/xbin/daemonsu',
    '/system/etc/init.d/99SuperSUDaemon',
    '/system/bin/.ext/.su',
    '/system/usr/we-need-root/su-backup',
    '/system/xbin/mu'
  ];

  for (final path in rootIndicators) {
    if (await File(path).exists()) return true;
  }

  final rootManagementApps = [
    'com.noshufou.android.su',
    'eu.chainfire.supersu',
    'com.koushikdutta.superuser',
    'com.thirdparty.superuser',
    'com.yellowes.su'
  ];

  for (final app in rootManagementApps) {
    if (await File('/data/app/$app-1/base.apk').exists() ||
        await File('/data/app/$app-2/base.apk').exists()) return true;
  }

  return false;
}

Future<bool> _isIOSJailbroken(IosDeviceInfo iosInfo) async {
  if (!iosInfo.isPhysicalDevice) return true;

  final jailbreakIndicators = [
    '/Applications/Cydia.app',
    '/Library/MobileSubstrate/MobileSubstrate.dylib',
    '/bin/bash',
    '/usr/sbin/sshd',
    '/etc/apt',
    '/private/var/lib/apt/',
    '/private/var/lib/cydia',
    '/private/var/stash'
  ];

  for (final path in jailbreakIndicators) {
    if (await File(path).exists()) return true;
  }

  const jailbreakTools = [
    'cydia',
    'substrate',
    'electra',
    'unc0ver',
    'checkra1n'
  ];
  for (final tool in jailbreakTools) {
    if (iosInfo.systemVersion.toLowerCase().contains(tool)) return true;
  }

  return false;
}
