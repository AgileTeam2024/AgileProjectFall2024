import 'package:json_annotation/json_annotation.dart';

enum ProductCategory {
  @JsonValue('Real-Estate')
  realEstate,
  @JsonValue('Automobile')
  automobile,
  @JsonValue('Digital & Electronics')
  digitalAndElectronics,
  @JsonValue('Kitchenware')
  kitchenware,
  @JsonValue('Personal Items')
  personalItems,
  @JsonValue('Entertainment')
  entertainment,
  @JsonValue('Others')
  others;


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
