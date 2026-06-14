import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/catalog_item.dart';
import '../models/enums.dart';
import '../models/medication.dart';

/// CRUD over catalog items (triggers, symptoms, relief) and medications.
class CatalogRepository {
  CatalogRepository(this._catalog, this._medications);

  final Box<CatalogItem> _catalog;
  final Box<Medication> _medications;
  final _uuid = const Uuid();

  // --- Catalog items ---

  List<CatalogItem> byKind(CatalogKind kind) {
    final list = _catalog.values.where((c) => c.kind == kind).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<CatalogItem> all() => _catalog.values.toList();

  CatalogItem? byId(String id) => _catalog.get(id);

  /// How many custom items exist across all kinds + medications. Used to enforce
  /// the free-tier custom limit.
  int customCount() {
    final catalog = _catalog.values.where((c) => c.isCustom).length;
    final meds = _medications.values.where((m) => _isCustomMed(m)).length;
    return catalog + meds;
  }

  Future<CatalogItem> addCustom(String name, CatalogKind kind) async {
    final item = CatalogItem(
      id: _uuid.v4(),
      name: name.trim(),
      kind: kind,
      isCustom: true,
    );
    await _catalog.put(item.id, item);
    return item;
  }

  Future<void> deleteCatalog(String id) async => _catalog.delete(id);

  // --- Medications ---

  List<Medication> medications() {
    final list = _medications.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Medication? medById(String id) => _medications.get(id);

  Future<Medication> addMedication(
    String name, {
    double? defaultDoseMg,
    int kind = 0,
  }) async {
    final med = Medication(
      id: 'custom_${_uuid.v4()}',
      name: name.trim(),
      defaultDoseMg: defaultDoseMg,
      kind: kind,
    );
    await _medications.put(med.id, med);
    return med;
  }

  Future<void> deleteMedication(String id) async => _medications.delete(id);

  /// Custom medications use a uuid-prefixed id; seeded ones use slugs.
  bool _isCustomMed(Medication m) => m.id.startsWith('custom_');

  Stream<BoxEvent> watchCatalog() => _catalog.watch();
  Stream<BoxEvent> watchMedications() => _medications.watch();
}
