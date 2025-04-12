package dev.adryanev.lovegalery

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            super.onCreate(savedInstanceState)
            Log.d(TAG, "MainActivity created successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity.onCreate: ${e.message}", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        try {
            super.configureFlutterEngine(flutterEngine)
            Log.d(TAG, "Flutter engine configured successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error configuring Flutter engine: ${e.message}", e)
        }
    }
}
