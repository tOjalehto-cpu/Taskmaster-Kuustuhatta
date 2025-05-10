import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task_calendar_page.dart'; // Importoi TaskCalendarPage

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now(); // Nykyinen päivä
  DateTime? _selectedDay; // Valittu päivä

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuukausikalenteri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // Avaa TaskCalendarPage ja välitä valittu päivä
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
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Valittu päivä: ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
        ],
      ),
    );
  }
}
