import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'calendar_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Alusta Hive
  await Hive.openBox('tasks'); // Avaa tai luo "tasks"-tietokanta
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskmaster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalendarView(), // Avaa kalenterinäkymä
    );
  }
}
