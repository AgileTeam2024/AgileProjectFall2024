enum SortType {
  priceASC,
  priceDSC,
  createdASC,
  createdDSC;

  String? get priceSort =>
      ![priceASC, priceDSC].contains(this) ? null : '$this'.substring(4);

  String? get createdSort =>
      ![createdASC, createdDSC].contains(this) ? null : '$this'.substring(6);

  @override
  String toString() => super.toString().split('.')[1];

  String toStringDisplay() => [
        'Price - Cheap first',
        'Price - Most Expensive first',
        'Create Date - Newest first',
        'Create Date - Oldest first'
      ][index];
}
