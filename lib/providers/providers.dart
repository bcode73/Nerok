import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_service.dart';
import '../data/catalog_repository.dart';
import '../data/episode_repository.dart';
import '../data/hive_service.dart';
import '../data/settings_repository.dart';
import '../models/app_settings.dart';
import '../models/catalog_item.dart';
import '../models/enums.dart';
import '../models/medication.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';

/// Provides the initialised [HiveService]. Overridden in `main()` with the
/// instance created after Hive has finished opening its boxes.
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('hiveServiceProvider must be overridden in main()');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
      'notificationServiceProvider must be overridden in main()');
});

// --- Repositories ---

final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  return EpisodeRepository(ref.watch(hiveServiceProvider).episodes);
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final hive = ref.watch(hiveServiceProvider);
  return CatalogRepository(hive.catalog, hive.medications);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(hiveServiceProvider).settings);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(hiveServiceProvider));
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService(ref.watch(catalogRepositoryProvider));
});

// --- Catalog (reactive lists) ---

class CatalogNotifier extends Notifier<List<CatalogItem>> {
  @override
  List<CatalogItem> build() {
    final repo = ref.watch(catalogRepositoryProvider);
    final sub = repo.watchCatalog().listen((_) => _refresh());
    ref.onDispose(sub.cancel);
    return repo.all();
  }

  void _refresh() => state = ref.read(catalogRepositoryProvider).all();

  Future<CatalogItem> addCustom(String name, CatalogKind kind) async {
    final item =
        await ref.read(catalogRepositoryProvider).addCustom(name, kind);
    _refresh();
    return item;
  }

  Future<void> delete(String id) async {
    await ref.read(catalogRepositoryProvider).deleteCatalog(id);
    _refresh();
  }
}

final catalogProvider =
    NotifierProvider<CatalogNotifier, List<CatalogItem>>(CatalogNotifier.new);

/// Items filtered by kind, sorted by name.
final catalogByKindProvider =
    Provider.family<List<CatalogItem>, CatalogKind>((ref, kind) {
  final all = ref.watch(catalogProvider);
  final list = all.where((c) => c.kind == kind).toList();
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
});

class MedicationsNotifier extends Notifier<List<Medication>> {
  @override
  List<Medication> build() {
    final repo = ref.watch(catalogRepositoryProvider);
    final sub = repo.watchMedications().listen((_) => _refresh());
    ref.onDispose(sub.cancel);
    return repo.medications();
  }

  void _refresh() =>
      state = ref.read(catalogRepositoryProvider).medications();

  Future<Medication> add(String name,
      {double? defaultDoseMg, int kind = 0}) async {
    final med = await ref
        .read(catalogRepositoryProvider)
        .addMedication(name, defaultDoseMg: defaultDoseMg, kind: kind);
    _refresh();
    return med;
  }

  Future<void> delete(String id) async {
    await ref.read(catalogRepositoryProvider).deleteMedication(id);
    _refresh();
  }
}

final medicationsProvider =
    NotifierProvider<MedicationsNotifier, List<Medication>>(
        MedicationsNotifier.new);

/// Number of custom catalog items + medications (free tier limit check).
final customCountProvider = Provider<int>((ref) {
  ref.watch(catalogProvider);
  ref.watch(medicationsProvider);
  return ref.watch(catalogRepositoryProvider).customCount();
});

// --- Settings ---

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.get();
  }

  Future<void> update(AppSettings settings) async {
    await ref.read(settingsRepositoryProvider).save(settings);
    state = settings;
  }

  Future<void> completeOnboarding() async {
    await update(state.copyWith(onboardingDone: true));
  }

  Future<void> setReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    final next = state.copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    await update(next);
    final notifications = ref.read(notificationServiceProvider);
    if (next.reminderEnabled) {
      await notifications.scheduleDailyReminder(
        hour: next.reminderHour,
        minute: next.reminderMinute,
      );
    } else {
      await notifications.cancelDailyReminder();
    }
  }

  Future<void> setPatientName(String? name) async {
    final trimmed = name?.trim();
    await update(state.copyWith(
      patientName: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      clearPatientName: trimmed == null || trimmed.isEmpty,
    ));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
