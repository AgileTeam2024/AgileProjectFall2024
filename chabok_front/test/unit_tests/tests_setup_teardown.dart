import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void setUpWidgetTest(WidgetTester tester, [Size? size]) {
  tester.view.physicalSize = size ?? Size(1000, 1000);
  tester.view.devicePixelRatio = 1.0;
}

void tearDownWidgetTest(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
