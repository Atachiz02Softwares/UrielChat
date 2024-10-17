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
  // if (!androidInfo.isPhysicalDevice) return true; TODO: Uncomment before release
  // if (androidInfo.tags.contains('test-keys')) return true;
  // if (androidInfo.systemFeatures.contains('android.software.device_admin')) return true;

  // Asynchronous root indicators check
  final rootIndicators = [
    '/system/app/Superuser.apk',
    '/sbin/su',
    '/system/bin/su',
    '/system/xbin/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/su'
  ];

  for (final path in rootIndicators) {
    if (await File(path).exists()) return true;
  }

  return false;
}

Future<bool> _isIOSJailbroken(IosDeviceInfo iosInfo) async {
  if (!iosInfo.isPhysicalDevice) return true;

  // Asynchronous jailbreak indicators check
  final jailbreakIndicators = [
    '/Applications/Cydia.app',
    '/Library/MobileSubstrate/MobileSubstrate.dylib',
    '/bin/bash',
    '/usr/sbin/sshd',
    '/etc/apt'
  ];

  for (final path in jailbreakIndicators) {
    if (await File(path).exists()) return true;
  }

  // Additional indicators found within the system version
  const jailbreakTools = ['cydia', 'substrate', 'electra', 'unc0ver'];
  for (final tool in jailbreakTools) {
    if (iosInfo.systemVersion.toLowerCase().contains(tool)) return true;
  }

  return false;
}
