import 'package:flutter/material.dart';

void setUpWidgetTest(tester) {
  tester.view.physicalSize = Size(1500, 1000);
  tester.view.devicePixelRatio = 1.0;
}

void tearDownWidgetTest(tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
