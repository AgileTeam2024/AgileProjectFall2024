enum ProductCategory {
  realEstate,
  automobile,
  digitalAndElectronics,
  kitchenware,
  personalItems,
  entertainment,
  others;

  static fromJson(String json) => values.firstWhere((e) => '$e' == json);

  static String toJson(ProductCategory category) => category.toString();

  @override
  String toString() => [
        'Real-Estate',
        'Automobile',
        'Digital & Electronics',
        'Kitchenware',
        'Personal Items',
        'Entertainment',
        'Others',
      ][index];
}
