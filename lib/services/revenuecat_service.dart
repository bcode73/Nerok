import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thin wrapper over RevenueCat. All entitlement reads funnel through here so
/// the rest of the app never touches the SDK directly.
class RevenueCatService {
  /// RevenueCat entitlement id that unlocks Pro.
  static const String entitlementId = 'pro';

  /// Offering identifier configured in the RevenueCat dashboard.
  static const String offeringId = 'default';

  // TODO(samuel): paste the iOS public SDK key from RevenueCat.
  static const String _iosApiKey = 'TODO(samuel): ios_public_sdk_key';

  /// Configure RevenueCat. Call once in `main()` after Hive init.
  static Future<void> configure() async {
    if (kIsWeb) return;
    await Purchases.setLogLevel(LogLevel.warn);
    try {
      await Purchases.configure(PurchasesConfiguration(_iosApiKey));
    } catch (e) {
      // Configuration failing (e.g. placeholder key in development) must not
      // crash the app — Pro simply stays locked.
      debugPrint('RevenueCat configure failed: $e');
    }
  }

  Future<bool> isPro() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<Offering?> currentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(offeringId) ?? offerings.current;
    } catch (e) {
      debugPrint('RevenueCat getOfferings failed: $e');
      return null;
    }
  }

  /// Purchase a package. Returns true when Pro is now active.
  /// Returns false when the user cancelled. Rethrows other errors.
  Future<bool> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo.entitlements.active
          .containsKey(entitlementId);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  /// Restore previous purchases. Returns true when Pro is active afterwards.
  Future<bool> restore() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(entitlementId);
  }

  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    Purchases.removeCustomerInfoUpdateListener(listener);
  }
}
