import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: MainAppBar(),
        body: const HomePage(),
      ),
    );
  }
}
