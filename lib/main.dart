import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'HiveDatabaseFlutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("Box");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Hivedatabaseflutter(),
    );
  }
}
