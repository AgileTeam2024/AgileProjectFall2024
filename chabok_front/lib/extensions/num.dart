extension NumExtension on num {
  String get compact {
    if (this < 1_000) return '$this';
    if (this < 1_000_000) return '${this / 1000}K';
    if (this < 1_000_000_000) return '${this / 1000_000}M';
    return '${this / 1_000_000_000}B';
  }
}
