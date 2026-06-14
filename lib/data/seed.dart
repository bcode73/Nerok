import '../models/catalog_item.dart';
import '../models/enums.dart';
import '../models/medication.dart';

/// Default catalog items and medications, populated on first launch so logging
/// is fast immediately. Ids are stable slugs so backups stay portable.
abstract final class Seed {
  static List<CatalogItem> catalogItems() => [
        // Triggers
        _t('poor_sleep', 'Poor sleep'),
        _t('skipped_meal', 'Skipped meal'),
        _t('stress', 'Stress'),
        _t('bright_light', 'Bright light'),
        _t('screen_time', 'Screen time'),
        _t('dehydration', 'Dehydration'),
        _t('weather_change', 'Weather change'),
        _t('caffeine', 'Caffeine'),
        _t('hormonal', 'Hormonal'),
        _t('alcohol', 'Alcohol'),
        _t('loud_noise', 'Loud noise'),
        _t('strong_smell', 'Strong smell'),
        // Symptoms
        _s('aura', 'Aura'),
        _s('nausea', 'Nausea'),
        _s('light_sensitivity', 'Light sensitivity'),
        _s('sound_sensitivity', 'Sound sensitivity'),
        _s('throbbing', 'Throbbing'),
        _s('dizziness', 'Dizziness'),
        // Relief
        _r('dark_room', 'Dark room'),
        _r('sleep', 'Sleep'),
        _r('cold_compress', 'Cold compress'),
        _r('hydration', 'Hydration'),
        _r('caffeine_relief', 'Caffeine'),
      ];

  static List<Medication> medications() => [
        Medication(id: 'ibuprofen', name: 'Ibuprofen', defaultDoseMg: 400),
        Medication(
            id: 'acetaminophen', name: 'Acetaminophen', defaultDoseMg: 500),
        Medication(id: 'sumatriptan', name: 'Sumatriptan', defaultDoseMg: 50),
        Medication(id: 'rizatriptan', name: 'Rizatriptan', defaultDoseMg: 10),
        Medication(id: 'naproxen', name: 'Naproxen', defaultDoseMg: 250),
      ];

  static CatalogItem _t(String id, String name) =>
      CatalogItem(id: id, name: name, kind: CatalogKind.trigger);

  static CatalogItem _s(String id, String name) =>
      CatalogItem(id: id, name: name, kind: CatalogKind.symptom);

  static CatalogItem _r(String id, String name) =>
      CatalogItem(id: id, name: name, kind: CatalogKind.relief);
}
