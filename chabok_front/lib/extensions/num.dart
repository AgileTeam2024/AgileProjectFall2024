extension NumExtension on num {
  String get decimalFormat => toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match m) => ",",
      );

  String get priceFormat => '$decimalFormat ᴵᴿᴿ';
}
