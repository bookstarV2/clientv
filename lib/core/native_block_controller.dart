import 'package:flutter/services.dart';

class NativeBlockController {
  static const MethodChannel _channel = MethodChannel('com.example.blocker/control');

  /// 네이티브에 차단 모드 시작을 요청합니다.
  Future<void> startBlocking() async {
    try {
      await _channel.invokeMethod('startBlock');
      print('Blocking started on native side.');
    } on PlatformException catch (e) {
      print("Failed to start blocking: '${e.message}'.");
    }
  }

  /// 네이티브에 차단 모드 해제를 요청합니다.
  Future<void> stopBlocking() async {
    try {
      await _channel.invokeMethod('stopBlock');
      print('Blocking stopped on native side.');
    } on PlatformException catch (e) {
      print("Failed to stop blocking: '${e.message}'.");
    }
  }

  /// 네이티브에 접근성 권한 요청 (설정 화면으로 이동)을 요청합니다.
  /// 설정 화면이 열렸으면 true, 이미 권한이 부여되었으면 false를 반환합니다.
  Future<bool> requestPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('requestPermission');
      print('Permission request sent to native side. Result: $result');
      return result ?? false; // true if settings were opened, false if already enabled
    } on PlatformException catch (e) {
      print("Failed to request permission: '${e.message}'.");
      return false;
    }
  }

  /// 네이티브에 접근성 권한 상태를 확인을 요청합니다.
  /// 권한이 부여되었으면 true, 아니면 false를 반환합니다.
  Future<bool> checkPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('checkPermission');
      print('Permission check result from native side: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print("Failed to check permission: '${e.message}'.");
      return false;
    }
  }
}
