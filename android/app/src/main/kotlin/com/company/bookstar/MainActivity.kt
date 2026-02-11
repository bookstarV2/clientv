package com.company.bookstar

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Channel name as requested
    private val CHANNEL = "com.company.bookstar/control"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBlock" -> {
                    val prefs = getSharedPreferences(FocusAccessibilityService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putBoolean(FocusAccessibilityService.KEY_IS_ACTIVE, true).apply()
                    result.success(true)
                }
                "stopBlock" -> {
                    val prefs = getSharedPreferences(FocusAccessibilityService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putBoolean(FocusAccessibilityService.KEY_IS_ACTIVE, false).apply()
                    result.success(true)
                }
                "requestPermission" -> {
                    if (!isAccessibilityServiceEnabled()) {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        // Add flags to ensure proper navigation behavior
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true) // Indicates we launched the settings
                    } else {
                        result.success(false) // Permission already granted
                    }
                }
                "checkPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Helper method to check if the Accessibility Service is enabled
    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, FocusAccessibilityService::class.java)
        
        val enabledServicesSetting = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledComponent = ComponentName.unflattenFromString(componentNameString)
            if (enabledComponent != null && enabledComponent == expectedComponentName) {
                return true
            }
        }
        return false
    }
}
