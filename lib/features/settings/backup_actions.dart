import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/episodes_provider.dart';
import '../../providers/providers.dart';

/// JSON backup export / restore. All on-device — the share sheet hands the
/// bytes to the OS; restore reads a file the user picks.
abstract final class BackupActions {
  static Future<void> export(BuildContext context, WidgetRef ref) async {
    final json = ref.read(backupServiceProvider).exportJson();
    final bytes = Uint8List.fromList(utf8.encode(json));
    final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final file = XFile.fromData(
      bytes,
      name: 'nerok-backup-$stamp.json',
      mimeType: 'application/json',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: ['nerok-backup-$stamp.json'],
        text: 'Nerok backup',
      ),
    );
  }

  static Future<void> restore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from file?'),
        content: const Text(
          'This replaces all current data on this device with the contents '
          'of the backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final data = result.files.single.bytes;
    if (data == null) {
      if (context.mounted) _toast(context, 'Could not read that file.');
      return;
    }

    try {
      final jsonStr = utf8.decode(data);
      await ref.read(backupServiceProvider).importJson(jsonStr);
      // Refresh the in-memory providers from the new boxes.
      ref.invalidate(episodesProvider);
      ref.invalidate(catalogProvider);
      ref.invalidate(medicationsProvider);
      ref.invalidate(settingsProvider);
      if (context.mounted) _toast(context, 'Backup restored.');
    } on FormatException {
      if (context.mounted) _toast(context, 'That is not a valid Nerok backup file.');
    } catch (_) {
      if (context.mounted) _toast(context, 'Restore failed.');
    }
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
