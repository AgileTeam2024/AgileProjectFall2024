enum ProductStatus {
  available,
  reserved,
  sold;

  static fromJson(String json) => values.firstWhere((e) => '$e' == json);

  static String toJson(ProductStatus status) => status.toString();

  @override
  String toString() => ['for sale', 'reserved', 'sold'][index];

  String toStringDisplay() => ['Available', 'Reserved', 'Sold'][index];
}
