import 'package:chabok_front/services/router.dart';
import 'package:flutter/material.dart';

class MainFAB extends FloatingActionButton {
  MainFAB({super.key})
      : super.extended(
          onPressed: () => RouterService.go('/create-product'),
          icon: Icon(Icons.add),
          label: Text('Create Product'),
          isExtended: true,
        );
}
