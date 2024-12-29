extension StringPatternCheck on String {
  bool get containsNumeric => RegExp(r'[0-9]').hasMatch(this);

  bool get containsAlphabet => RegExp(r'[a-zA-Z]').hasMatch(this);

  bool get isEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);
}
