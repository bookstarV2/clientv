import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI

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
        do {
            let encoded = try JSONEncoder().encode(selection)
            UserDefaults.standard.set(encoded, forKey: "savedSelection")
        } catch {
            print("Failed to encode FamilyActivitySelection: \(error)")
        }
    }
    
    private func loadSelection() {
        guard let saved = UserDefaults.standard.data(forKey: "savedSelection") else { return }
        do {
            selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: saved)
        } catch {
            print("Failed to decode FamilyActivitySelection: \(error)")
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
