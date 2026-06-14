/// Free tier allows up to a small number of custom catalog items / meds.
abstract final class CustomLimit {
  static const int freeMax = 3;

  static bool canAdd({required bool isPro, required int currentCount}) {
    if (isPro) return true;
    return currentCount < freeMax;
  }
}
