package com.example.smart_alarm_app

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/**
 * Special activity that can show over the lock screen
 * This activity is launched directly by the AlarmReceiver
 */
class AlarmActivity : FlutterActivity() {
    private val TAG = "AlarmActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "🚀 AlarmActivity onCreate")
        
        // Set flags to show over lock screen BEFORE calling super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "✅ AlarmActivity created with lock screen override flags")
        
        // Extract alarm data from intent
        val alarmId = intent.getIntExtra(AlarmReceiver.EXTRA_ALARM_ID, -1)
        val alarmLabel = intent.getStringExtra(AlarmReceiver.EXTRA_ALARM_LABEL)
        Log.d(TAG, "Alarm ID: $alarmId, Label: $alarmLabel")
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "📱 AlarmActivity resumed")
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "⏸️ AlarmActivity paused")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🗑️ AlarmActivity destroyed")
    }
}
