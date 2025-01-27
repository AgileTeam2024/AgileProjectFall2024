

enum ProductCategory {
  realEstate,
  automobile,
  digitalAndElectronics,
  kitchenware,
  personalItems,
  entertainment,
  others;

  String toJson() => toString();

  factory ProductCategory.fromJson(String json) =>
      values.where((v) => '$v' == json).first;

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
