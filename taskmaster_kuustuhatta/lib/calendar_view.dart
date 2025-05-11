import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
              selectedDecoration: BoxDecoration(
                color: Colors.orange, // Valitun päivän korostusväri.
                shape: BoxShape.circle, // Valitun päivän muoto.
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Piilottaa kalenterin formaattipainikkeen.
              titleCentered: true, // Keskittää kalenterin otsikon.
            ),
          ),
          // Näyttää valitun päivän tekstinä, jos päivä on valittu.
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Valittu päivä: ${_selectedDay!.toLocal().toString().split(' ')[0]}', // Näyttää valitun päivän muodossa "YYYY-MM-DD".
                style:
                    Theme.of(context).textTheme.headlineSmall, // Tekstin tyyli.
              ),
            ),
        ],
      ),
    );
  }
}
