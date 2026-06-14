import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/hive_service.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';
import 'services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hive = HiveService();
  await hive.init();

  final notifications = NotificationService();
  await notifications.init();

  // Configure RevenueCat after storage is ready. Safe to fail with a
  // placeholder key during development — Pro just stays locked.
  await RevenueCatService.configure();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hive),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const NerokApp(),
    ),
  );
}
