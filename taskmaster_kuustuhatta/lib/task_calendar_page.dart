import 'package:flutter/material.dart';

class TaskCalendarPage extends StatefulWidget {
  final DateTime selectedDate; // Valittu päivämäärä

  const TaskCalendarPage({super.key, required this.selectedDate});

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  final TextEditingController _taskController =
      TextEditingController(); // Tekstikentän ohjain
  List<Map<String, dynamic>> _tasks = []; // Tehtävälista
  int _selectedPriority = 1; // Oletusprioriteetti

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'name': _taskController.text,
          'done': false,
          'priority': _selectedPriority,
        });
        _taskController.clear(); // Tyhjennä tekstikenttä
        _selectedPriority = 1; // Palauta prioriteetti oletukseen
      });
    }
  }

  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done']; // Vaihda tehtävän tila
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index); // Poista tehtävä listasta
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tehtävät: ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Tehtävien lista
          Expanded(
            child:
                _tasks.isEmpty
                    ? const Center(
                      child: Text(
                        'Ei tehtäviä valitulle päivälle.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _tasks[index]['name'],
                            style: TextStyle(
                              decoration:
                                  _tasks[index]['done']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Prioriteetti: ${_tasks[index]['priority'] == 2
                                ? 'Tärkeä'
                                : _tasks[index]['priority'] == 1
                                ? 'Normaali'
                                : 'Ei niin tärkeä'}',
                          ),
                          leading: Checkbox(
                            value: _tasks[index]['done'],
                            onChanged: (value) {
                              if (value != null) {
                                _toggleTaskDone(index); // Vaihda tehtävän tila
                              }
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeTask(index); // Poista tehtävä
                            },
                          ),
                        );
                      },
                    ),
          ),
          // Tekstikenttä ja lisäyspainike
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Lisää uusi tehtävä',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('Tärkeä')),
                    DropdownMenuItem(value: 1, child: Text('Normaali')),
                    DropdownMenuItem(value: 0, child: Text('Ei niin tärkeä')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value; // Päivitä prioriteetti
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text('Lisää')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
