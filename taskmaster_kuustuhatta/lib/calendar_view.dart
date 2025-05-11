import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_service.dart'; // Importoi ilmoituspalvelu
import 'task_calendar_page.dart'; // Importoi TaskCalendarPage-näkymä

// Tämä widget näyttää kuukausikalenterinäkymän.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

// Tämä luokka hallitsee kalenterinäkymän tilaa.
class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay =
      DateTime.now(); // Nykyinen päivä, jota kalenteri näyttää.
  DateTime? _selectedDay; // Käyttäjän valitsema päivä.
  final Box _taskBox = Hive.box(
    'tasks',
  ); // Hive-tietokanta, jossa tehtävät tallennetaan.

  @override
  void initState() {
    super.initState();
    _scheduleHighPriorityNotifications();
  }

  // Tarkistaa, onko valitulle päivälle tehtäviä, joita ei ole merkitty tehdyiksi.
  bool _hasIncompleteTasks(DateTime day) {
    final String selectedDateString = day.toIso8601String().split('T')[0];
    final tasks =
        _taskBox.values.where((task) {
          final taskMap = Map<String, dynamic>.from(task as Map);
          return taskMap['date'] == selectedDateString &&
              taskMap['done'] == false;
        }).toList();

    return tasks.isNotEmpty;
  }

  // Aikatauluta korkean prioriteetin tehtävien ilmoitukset
  void _scheduleHighPriorityNotifications() {
    final tasks =
        _taskBox.values.where((task) {
          final taskMap = Map<String, dynamic>.from(task as Map);
          final taskDate = DateTime.parse(taskMap['date']);
          return taskMap['priority'] == 2 &&
              !taskMap['done'] &&
              taskDate.isAfter(DateTime.now());
        }).toList();

    for (var i = 0; i < tasks.length; i++) {
      final taskMap = Map<String, dynamic>.from(tasks[i] as Map);
      NotificationService.showNotification(
        i, // Ilmoituksen ID
        'Korkean prioriteetin tehtävä', // Otsikko
        '${taskMap['name']} erääntyy ${taskMap['date']}', // Viesti
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuukausikalenteri'), // Näkymän otsikko.
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Otsikkopalkin väri.
      ),
      body: Column(
        children: [
          // Kalenterikomponentti, joka näyttää kuukauden päivät.
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1), // Kalenterin ensimmäinen päivä.
            lastDay: DateTime.utc(2100, 12, 31), // Kalenterin viimeinen päivä.
            focusedDay: _focusedDay, // Päivä, jota kalenteri näyttää.
            selectedDayPredicate:
                (day) => isSameDay(
                  _selectedDay,
                  day,
                ), // Tarkistaa, onko päivä valittu.
            onDaySelected: (selectedDay, focusedDay) {
              // Kun käyttäjä valitsee päivän kalenterista.
              setState(() {
                _selectedDay = selectedDay; // Päivitetään valittu päivä.
                _focusedDay = focusedDay; // Päivitetään fokusoitu päivä.
              });

              // Avaa TaskCalendarPage-näkymän ja välittää valitun päivän.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TaskCalendarPage(selectedDate: selectedDay),
                ),
              );
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue, // Nykyisen päivän korostusväri.
                shape: BoxShape.circle, // Nykyisen päivän muoto.
              ),
              // selectedDecoration: BoxDecoration(
              //   color: Colors.orange, // Valitun päivän korostusväri.
              //   shape: BoxShape.circle, // Valitun päivän muoto.
              // ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Piilottaa kalenterin formaattipainikkeen.
              titleCentered: true, // Keskittää kalenterin otsikon.
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Tarkista, onko päivälle tehtäviä, joita ei ole tehty.
                if (_hasIncompleteTasks(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(
                        0.5,
                      ), // Päivän taustaväri.
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}', // Päivän numero.
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return null; // Käytä oletustyyliä, jos tehtäviä ei ole.
              },
            ),
          ),
          // Näyttää valitun päivän tekstinä ja tarkistaa, onko tehtäviä.
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _hasIncompleteTasks(_selectedDay!)
                    ? 'Valitulle päivälle on tehtäviä, joita ei ole tehty!'
                    : 'Ei tehtäviä valitulle päivälle.',
                style:
                    Theme.of(context).textTheme.headlineSmall, // Tekstin tyyli.
              ),
            ),
        ],
      ),
    );
  }
}
