import Flutter
import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import FamilyControls
import ManagedSettings
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "com.company.bookstar/control"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Kakao SDK Init
        if let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KakaoNativeAppKey") as? String {
             KakaoSDK.initSDK(appKey: kakaoKey)
        } else {
             print("Warning: KakaoNativeAppKey not found in Info.plist")
        }

        // MethodChannel Setup
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not a FlutterViewController")
        }
        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            // iOS 16.0 이상에서만 차단 기능 지원
            if #available(iOS 16.0, *) {
                guard let methodName = MethodName(rawValue: call.method) else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                switch methodName {
                case .requestPermission:
                    Task {
                        let granted = await BlockManager.shared.requestAuthorization()
                        result(granted)
                    }
                    
                case .checkPermission:
                    result(BlockManager.shared.isAuthorized())
                    
                case .startBlock:
                    BlockManager.shared.startBlocking()
                    result(true)
                    
                case .stopBlock:
                    BlockManager.shared.stopBlocking()
                    result(true)
                
                case .selectAppsToBlock:
                    BlockManager.shared.showSelectionPicker(in: controller)
                    result(true)
                }
            } else {
                // iOS 16 미만에서는 기능 미지원 처리
                if MethodName.allCases.map({ $0.rawValue }).contains(call.method) {
                    print("App blocking is only supported on iOS 16.0+")
                    result(false) 
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return super.application(app, open: url, options: options)
    }
}

extension AppDelegate {
    enum MethodName: String, CaseIterable {
        case requestPermission
        case checkPermission
        case startBlock
        case stopBlock
        case selectAppsToBlock
    }
}