import 'package:flutter/material.dart';

void setUpWidgetTest(tester) {
  tester.view.physicalSize = Size(1000, 1000);
  tester.view.devicePixelRatio = 1.0;
}

void tearDownWidgetTest(tester) {
  tester.view.physicalSize = Size(1000, 1000);
  tester.view.devicePixelRatio = 1.0;
}
