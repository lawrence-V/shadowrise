package com.example.smart_alarm_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * BroadcastReceiver that handles alarm triggers from Android AlarmManager
 * This allows alarms to fire even when the app is closed or phone is sleeping
 */
class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
        const val CHANNEL_ID = "alarm_channel"
        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_ALARM_LABEL = "alarm_label"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "🔔🔔🔔 AlarmReceiver: Alarm triggered! 🔔🔔🔔")
        
        val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, -1)
        val alarmLabel = intent.getStringExtra(EXTRA_ALARM_LABEL) ?: "Alarm"
        
        Log.d(TAG, "Alarm ID: $alarmId, Label: $alarmLabel")

        // Acquire wake lock to ensure the device wakes up
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or 
            PowerManager.ACQUIRE_CAUSES_WAKEUP or 
            PowerManager.ON_AFTER_RELEASE,
            "SmartAlarm:AlarmWakeLock"
        )
        wakeLock.acquire(60 * 1000L) // 60 seconds
        Log.d(TAG, "🔆 Wake lock acquired")

        // Create notification channel (required for Android O+)
        createNotificationChannel(context)

        // Vibrate the device
        vibrateDevice(context)

        // Launch the app with full-screen intent
        launchAlarmScreen(context, alarmId, alarmLabel)
        
        // Release wake lock after a short delay (alarm screen should take over)
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            if (wakeLock.isHeld) {
                wakeLock.release()
                Log.d(TAG, "🔅 Wake lock released")
            }
        }, 10000) // 10 seconds
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Smart Alarm"
            val descriptionText = "Alarm notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
                setBypassDnd(true)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun vibrateDevice(context: Context) {
        try {
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Create a repeating vibration pattern
                val timings = longArrayOf(0, 1000, 500, 1000, 500, 1000)
                val amplitudes = intArrayOf(0, 255, 0, 255, 0, 255)
                vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, 0))
            } else {
                @Suppress("DEPRECATION")
                val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, 0)
            }
            Log.d(TAG, "📳 Vibration started")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to vibrate: ${e.message}")
        }
    }

    private fun launchAlarmScreen(context: Context, alarmId: Int, alarmLabel: String) {
        Log.d(TAG, "🚀 Starting AlarmActivity...")
        
        // Create intent for AlarmActivity
        val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_ALARM_LABEL, alarmLabel)
            putExtra("launch_alarm", true)
        }
        
        // Try to start activity immediately
        try {
            context.startActivity(alarmIntent)
            Log.d(TAG, "✅ AlarmActivity started!")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to start activity: ${e.message}", e)
        }
        
        // Also create a notification as backup/reminder
        try {
            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                alarmId,
                alarmIntent,
                pendingIntentFlags
            )
            
            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("⏰ $alarmLabel")
                .setContentText("Alarm ringing! Tap to open.")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(pendingIntent, true)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build()
            
            NotificationManagerCompat.from(context).notify(alarmId, notification)
            Log.d(TAG, "📱 Notification shown")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to show notification: ${e.message}")
        }
    }
}
