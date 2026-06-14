import 'package:hive/hive.dart';

import '../models/app_settings.dart';
import 'hive_service.dart';

/// Reads and writes the single [AppSettings] record.
class SettingsRepository {
  SettingsRepository(this._box);

  final Box<AppSettings> _box;

  AppSettings get() => _box.get(Boxes.settingsKey) ?? AppSettings();

  Future<void> save(AppSettings settings) async {
    await _box.put(Boxes.settingsKey, settings);
  }

  Stream<BoxEvent> watch() => _box.watch(key: Boxes.settingsKey);
}
