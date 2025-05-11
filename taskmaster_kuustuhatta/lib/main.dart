import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'calendar_view.dart'; // Importoi kalenterinäkymä

// Sovelluksen pääfunktio
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Varmistaa, että widgetit alustetaan ennen sovelluksen käynnistämistä
  await Hive.initFlutter(); // Alustaa Hive-tietokannan
  await Hive.openBox('tasks'); // Avaa tai luo "tasks"-nimisen tietokannan
  runApp(const MyApp()); // Käynnistää sovelluksen
}

// Sovelluksen pääwidget
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktori, joka ottaa vastaan avaimen (key)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskmaster', // Sovelluksen nimi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ), // Väriteema, joka perustuu siniseen väriin
        useMaterial3: true, // Käyttää Material Design 3 -tyyliä
      ),
      home:
          const CalendarView(), // Avaa kalenterinäkymä sovelluksen aloitussivuksi
    );
  }
}
