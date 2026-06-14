import 'dart:convert';

import '../models/app_settings.dart';
import '../models/catalog_item.dart';
import '../models/episode.dart';
import '../models/medication.dart';
import 'hive_service.dart';

/// JSON backup export / import over all on-device data. No network involved —
/// the bytes are handed to the OS share sheet (export) or read from a picked
/// file (restore).
class BackupService {
  BackupService(this._hive);

  final HiveService _hive;

  static const int formatVersion = 1;

  /// Serialise everything to a pretty JSON string.
  String exportJson() {
    final data = {
      'format': 'nerok-backup',
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'episodes': _hive.episodes.values.map((e) => e.toJson()).toList(),
      'catalog': _hive.catalog.values.map((c) => c.toJson()).toList(),
      'medications': _hive.medications.values.map((m) => m.toJson()).toList(),
      'settings': _hive.settings.get(Boxes.settingsKey)?.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Replace all local data with the contents of [jsonStr].
  /// Throws [FormatException] when the file is not a Nerok backup.
  Future<void> importJson(String jsonStr) async {
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! Map || decoded['format'] != 'nerok-backup') {
      throw const FormatException('Not a Nerok backup file.');
    }
    final map = decoded.cast<String, dynamic>();

    final episodes = (map['episodes'] as List? ?? [])
        .map((e) => Episode.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final catalog = (map['catalog'] as List? ?? [])
        .map((c) => CatalogItem.fromJson((c as Map).cast<String, dynamic>()))
        .toList();
    final meds = (map['medications'] as List? ?? [])
        .map((m) => Medication.fromJson((m as Map).cast<String, dynamic>()))
        .toList();
    final settings = map['settings'] == null
        ? AppSettings()
        : AppSettings.fromJson((map['settings'] as Map).cast<String, dynamic>());

    await _hive.episodes.clear();
    await _hive.catalog.clear();
    await _hive.medications.clear();

    for (final e in episodes) {
      await _hive.episodes.put(e.id, e);
    }
    for (final c in catalog) {
      await _hive.catalog.put(c.id, c);
    }
    for (final m in meds) {
      await _hive.medications.put(m.id, m);
    }
    await _hive.settings.put(Boxes.settingsKey, settings);
  }
}
