import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the optional daily logging reminder. Permission is requested on
/// first enable, never at launch.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    tz.initializeTimeZones();

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings =
        InitializationSettings(iOS: iosInit, android: androidInit);

    await _plugin.initialize(settings);
    _initialised = true;
  }

  /// Ask the OS for notification permission. Returns true when granted.
  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await init();
    await cancelDailyReminder();

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily reminder',
        channelDescription: 'A gentle nudge to log how your head felt today.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'How is your head today?',
      'Take a few seconds to log how you felt.',
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await init();
    await _plugin.cancel(_dailyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
