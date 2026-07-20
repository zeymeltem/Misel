/// Saf ekonomi hesaplamaları (Firestore'a dokunmaz). Yazım işlemleri
/// [UserRepository]'de.
class EconomyService {
  /// Hedef süreye göre kazanılacak coin miktarı (seans başarıyla bitince
  /// gerçekte kazanılan miktarla aynı formül; kurulum ekranında önizleme için).
  static int estimateCoins(int targetMinutes) {
    return (targetMinutes * (0.25 + targetMinutes / 160)).round();
  }
}
