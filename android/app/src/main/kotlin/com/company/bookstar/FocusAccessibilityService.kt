package com.company.bookstar

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log

class FocusAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "FocusAccessibility"
        const val PREFS_NAME = "FocusModePrefs"
        const val KEY_IS_ACTIVE = "is_active"
        // Whitelisted packages: Our app + Keyboards
        private val WHITELISTED_PACKAGES = setOf(
            "com.company.bookstar",
            "com.google.android.inputmethod.latin", // Gboard
            "com.samsung.android.honeyboard" // Samsung Keyboard
        )
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // We only care about window state changes (app switching)
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val packageName = event.packageName?.toString() ?: return
        
        // Check if blocking is enabled from SharedPrefs
        val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val isBlocking = prefs.getBoolean(KEY_IS_ACTIVE, false)

        if (isBlocking) {
            if (!isPackageAllowed(packageName)) {
                Log.d(TAG, "Blocking package: $packageName")
                
                // Action: Bring our app to front to make it clear why
                val intent = packageManager.getLaunchIntentForPackage("com.company.bookstar")
                if (intent != null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    startActivity(intent)
                }
            }
        }
    }

    private fun isPackageAllowed(packageName: String): Boolean {
        // 1. Check exact whitelist
        if (WHITELISTED_PACKAGES.contains(packageName)) return true
        
        // 2. Allow input methods (Keyboards) - Critical for user interaction
        if (packageName.contains("inputmethod") || packageName.contains("keyboard")) return true

        // 3. Allow System UI (Notifications, Quick Settings)
        if (packageName == "com.android.systemui") return true
        
        return false
    }

    override fun onInterrupt() {
        Log.d(TAG, "FocusAccessibilityService interrupted")
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "FocusAccessibilityService connected")
    }
}
