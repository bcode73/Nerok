import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/catalog_item.dart';
import '../models/enums.dart';
import '../models/episode.dart';
import '../models/med_log.dart';
import '../models/medication.dart';
import 'seed.dart';

/// Box names — single source of truth.
abstract final class Boxes {
  static const episodes = 'episodes';
  static const catalog = 'catalog';
  static const medications = 'medications';
  static const settings = 'settings';

  /// Key inside the settings box that holds the single [AppSettings] record.
  static const settingsKey = 'app_settings';
}

/// Initialises Hive, registers adapters, opens boxes and seeds defaults on
/// first launch.
class HiveService {
  late final Box<Episode> episodes;
  late final Box<CatalogItem> catalog;
  late final Box<Medication> medications;
  late final Box<AppSettings> settings;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (idempotent guard so hot restart does not throw).
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(EpisodeAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MedLogAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CatalogItemAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MedicationAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(EpisodeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(CatalogKindAdapter());
    }

    episodes = await Hive.openBox<Episode>(Boxes.episodes);
    catalog = await Hive.openBox<CatalogItem>(Boxes.catalog);
    medications = await Hive.openBox<Medication>(Boxes.medications);
    settings = await Hive.openBox<AppSettings>(Boxes.settings);

    await _seedIfEmpty();
  }

  Future<void> _seedIfEmpty() async {
    if (catalog.isEmpty) {
      for (final item in Seed.catalogItems()) {
        await catalog.put(item.id, item);
      }
    }
    if (medications.isEmpty) {
      for (final med in Seed.medications()) {
        await medications.put(med.id, med);
      }
    }
    if (settings.get(Boxes.settingsKey) == null) {
      await settings.put(Boxes.settingsKey, AppSettings());
    }
  }
}
