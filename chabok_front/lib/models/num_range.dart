class NumRange {
  final num? minValue, maxValue;

  NumRange({this.minValue, this.maxValue});

  bool isBetween(num value) {
    if (minValue != null && value < minValue!) return false;
    if (maxValue != null && value > maxValue!) return false;
    return true;
  }
}