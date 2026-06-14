import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuecat_service.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Whether the user currently has the `pro` entitlement. Seeds from
/// RevenueCat's cached customer info and stays in sync via the update listener.
class ProNotifier extends Notifier<bool> {
  void Function(CustomerInfo)? _listener;

  @override
  bool build() {
    final service = ref.watch(revenueCatServiceProvider);

    _listener = (info) {
      state = info.entitlements.active
          .containsKey(RevenueCatService.entitlementId);
    };
    service.addCustomerInfoUpdateListener(_listener!);
    ref.onDispose(() {
      if (_listener != null) {
        service.removeCustomerInfoUpdateListener(_listener!);
      }
    });

    // Kick off the initial async read; default to locked until it resolves.
    service.isPro().then((value) => state = value);
    return false;
  }

  /// Force a re-read, e.g. after a restore.
  Future<void> refresh() async {
    state = await ref.read(revenueCatServiceProvider).isPro();
  }
}

final isProProvider = NotifierProvider<ProNotifier, bool>(ProNotifier.new);
