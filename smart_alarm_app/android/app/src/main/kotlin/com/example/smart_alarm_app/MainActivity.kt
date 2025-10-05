package com.example.smart_alarm_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.smart_alarm_app/alarm"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    try {
                        val alarmId = call.argument<Int>("id")
                        val alarmLabel = call.argument<String>("label")
                        val triggerTime = call.argument<Long>("triggerTime")
                        
                        if (alarmId == null || alarmLabel == null || triggerTime == null) {
                            result.error("INVALID_ARGS", "Missing required arguments", null)
                            return@setMethodCallHandler
                        }
                        
                        scheduleExactAlarm(alarmId, alarmLabel, triggerTime)
                        result.success(true)
                        Log.d(TAG, "✅ Alarm scheduled: ID=$alarmId, Label=$alarmLabel, Time=$triggerTime")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to schedule alarm: ${e.message}", e)
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelAlarm" -> {
                    try {
                        val alarmId = call.argument<Int>("id")
                        if (alarmId == null) {
                            result.error("INVALID_ARGS", "Missing alarm ID", null)
                            return@setMethodCallHandler
                        }
                        
                        cancelAlarm(alarmId)
                        result.success(true)
                        Log.d(TAG, "✅ Alarm cancelled: ID=$alarmId")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to cancel alarm: ${e.message}", e)
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        // Handle alarm intent if app was launched by alarm
        handleAlarmIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAlarmIntent(intent)
    }

    private fun handleAlarmIntent(intent: Intent?) {
        if (intent?.getBooleanExtra("launch_alarm", false) == true) {
            val alarmId = intent.getIntExtra(AlarmReceiver.EXTRA_ALARM_ID, -1)
            val alarmLabel = intent.getStringExtra(AlarmReceiver.EXTRA_ALARM_LABEL)
            Log.d(TAG, "📱 App launched by alarm: ID=$alarmId, Label=$alarmLabel")
            
            // Send event to Flutter to navigate to alarm screen
            // This will be handled by the Flutter side
        }
    }

    private fun scheduleExactAlarm(alarmId: Int, alarmLabel: String, triggerTimeMillis: Long) {
        Log.d(TAG, "📅 scheduleExactAlarm called:")
        Log.d(TAG, "   - Alarm ID: $alarmId")
        Log.d(TAG, "   - Label: $alarmLabel")
        Log.d(TAG, "   - Trigger time (millis): $triggerTimeMillis")
        Log.d(TAG, "   - Trigger time (date): ${java.util.Date(triggerTimeMillis)}")
        Log.d(TAG, "   - Current time: ${java.util.Date()}")
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Check if we have permission to schedule exact alarms (Android 12+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val canSchedule = alarmManager.canScheduleExactAlarms()
            Log.d(TAG, "   - Can schedule exact alarms: $canSchedule")
            if (!canSchedule) {
                Log.e(TAG, "❌ PERMISSION DENIED: Cannot schedule exact alarms!")
                Log.e(TAG, "   User must grant 'Alarms & reminders' permission in Settings")
                return
            }
        }
        
        // Create intent for the alarm receiver
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = "com.example.smart_alarm_app.ALARM_TRIGGER"
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_ALARM_LABEL, alarmLabel)
        }
        
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId,
            intent,
            pendingIntentFlags
        )
        
        // Schedule the alarm
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                Log.d(TAG, "✅ Alarm scheduled using setExactAndAllowWhileIdle")
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                Log.d(TAG, "✅ Alarm scheduled using setExact")
            }
            
            Log.d(TAG, "🎉 SUCCESS! Alarm ID $alarmId scheduled for ${java.util.Date(triggerTimeMillis)}")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to schedule alarm: ${e.message}", e)
            throw e
        }
    }

    private fun cancelAlarm(alarmId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = "com.example.smart_alarm_app.ALARM_TRIGGER"
        }
        
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId,
            intent,
            pendingIntentFlags
        )
        
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        
        Log.d(TAG, "🚫 Alarm cancelled: ID=$alarmId")
    }
}
