import 'package:chabok_front/services/router.dart';
import 'package:flutter/material.dart';

class MainFAB extends FloatingActionButton {
  MainFAB({
    super.key,
    IconData? icon,
    String? label,
    Function()? onPressed,
  }) : super.extended(
          onPressed: onPressed ?? () => RouterService.go('/create-product'),
          icon: Icon(icon ?? Icons.add),
          label: Text(label ?? 'Create Product'),
          isExtended: true,
        );
}
