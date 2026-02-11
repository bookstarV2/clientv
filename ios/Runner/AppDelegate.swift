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
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            // iOS 16.0 이상에서만 차단 기능 지원
            if #available(iOS 16.0, *) {
                switch call.method {
                case "requestPermission":
                    Task {
                        let granted = await BlockManager.shared.requestAuthorization()
                        result(granted)
                    }
                    
                case "checkPermission":
                    result(BlockManager.shared.isAuthorized())
                    
                case "startBlock":
                    BlockManager.shared.startBlocking()
                    result(true)
                    
                case "stopBlock":
                    BlockManager.shared.stopBlocking()
                    result(true)
                
                case "selectAppsToBlock":
                    BlockManager.shared.showSelectionPicker(in: controller)
                    result(true)
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
            } else {
                // iOS 16 미만에서는 기능 미지원 처리
                if ["requestPermission", "checkPermission", "startBlock", "stopBlock", "selectAppsToBlock"].contains(call.method) {
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

// =============================================================================
// BlockManager & Helpers
// =============================================================================

@available(iOS 16.0, *)
class BlockManager: ObservableObject {
    static let shared = BlockManager()
    
    // Store for managing blocking settings
    private let store = ManagedSettingsStore()
    
    var selection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    private init() {
        loadSelection()
    }
    
    private func saveSelection() {
        if let encoded = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(encoded, forKey: "savedSelection")
        }
    }
    
    private func loadSelection() {
        if let saved = UserDefaults.standard.data(forKey: "savedSelection"),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: saved) {
            selection = decoded
        }
    }
    
    // 1. Request Authorization
    func requestAuthorization() async -> Bool {
        do {
            // requestAuthorization(for: .individual) is available on iOS 16+
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            return true
        } catch {
            print("Error requesting authorization: \(error)")
            return false
        }
    }
    
    // 2. Show App Selection Picker
    func showSelectionPicker(in viewController: UIViewController) {
        let pickerWrapper = PickerWrapper(selection: Binding(
            get: { self.selection },
            set: { self.selection = $0 }
        ))
        let hostingController = UIHostingController(rootView: pickerWrapper)
        viewController.present(hostingController, animated: true)
    }
    
    // 3. Start Blocking
    func startBlocking() {
        // Clear existing settings first to ensure update triggers
        store.clearAllSettings()
        
        // Block all categories effectively blocks almost all apps.
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
        
        // Also apply individual selections if any
        store.shield.applications = selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens
        
        print("Blocking started: All Categories blocked.")
    }
    
    // 4. Stop Blocking
    func stopBlocking() {
        store.clearAllSettings()
        print("Blocking stopped.")
    }
    
    // Check Authorization Status
    func isAuthorized() -> Bool {
        return AuthorizationCenter.shared.authorizationStatus == .approved
    }
}

@available(iOS 16.0, *)
struct PickerWrapper: View {
    @Binding var selection: FamilyActivitySelection
    
    var body: some View {
        FamilyActivityPicker(selection: $selection)
    }
}