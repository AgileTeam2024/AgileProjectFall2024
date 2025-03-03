enum SortType {
  priceASC,
  priceDSC,
  createdASC,
  createdDSC;

  String? get priceSort => ![priceASC, priceDSC].contains(this)
      ? null
      : '$this'.substring(5).toLowerCase();

  String? get createdSort => ![createdASC, createdDSC].contains(this)
      ? null
      : '$this'.substring(7).toLowerCase();

  @override
  String toString() => super.toString().split('.')[1];

  String toStringDisplay() => [
        'Price - Cheapest first',
        'Price - Most Expensive first',
        'Create Date - Oldest first',
        'Create Date - Newest first',
      ][index];
}
