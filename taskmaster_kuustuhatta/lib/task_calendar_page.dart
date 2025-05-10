import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskCalendarPage extends StatefulWidget {
  final DateTime selectedDate; // Valittu päivämäärä

  const TaskCalendarPage({super.key, required this.selectedDate});

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  final Box _taskBox = Hive.box('tasks'); // Hive-tietokanta
  final TextEditingController _taskController =
      TextEditingController(); // Tekstikentän ohjain
  List<Map<String, dynamic>> _tasks = []; // Tehtävälista
  int _selectedPriority = 1; // Oletusprioriteetti

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Lataa tehtävät tietokannasta
  }

  void _loadTasks() {
    final data = _taskBox.values.toList();
    final selectedDateString =
        widget.selectedDate.toIso8601String().split(
          'T',
        )[0]; // Päivämäärä muodossa "YYYY-MM-DD"

    setState(() {
      _tasks =
          data
              .map((task) => Map<String, dynamic>.from(task as Map))
              .where(
                (task) => task['date'] == selectedDateString,
              ) // Suodata valitun päivän tehtävät
              .toList();
    });
  }

  void _saveTask(Map<String, dynamic> task) {
    _taskBox.add(task); // Lisää tehtävä tietokantaan
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = {
        'name': _taskController.text,
        'done': false,
        'priority': _selectedPriority,
        'date':
            widget.selectedDate.toIso8601String().split(
              'T',
            )[0], // Lisää päivämäärä
      };

      setState(() {
        _tasks.add(newTask); // Lisää tehtävä listaan
        _saveTask(newTask); // Tallenna tehtävä tietokantaan
        _taskController.clear(); // Tyhjennä tekstikenttä
        _selectedPriority = 1; // Palauta prioriteetti oletukseen
      });
    }
  }

  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done']; // Vaihda tehtävän tila
      _taskBox.putAt(index, _tasks[index]); // Päivitä tietokanta
    });
  }

  void _removeTask(int index) {
    setState(() {
      _taskBox.deleteAt(index); // Poista tehtävä tietokannasta
      _tasks.removeAt(index); // Poista tehtävä listasta
    });
  }

  void _updateTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: _tasks[index]['name'],
    );
    int updatedPriority = _tasks[index]['priority'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Muokkaa tehtävää'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: 'Tehtävän nimi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: updatedPriority,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('Tärkeä')),
                  DropdownMenuItem(value: 1, child: Text('Normaali')),
                  DropdownMenuItem(value: 0, child: Text('Ei niin tärkeä')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      updatedPriority = value; // Päivitä prioriteetti
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Sulje dialogi ilman muutoksia
              },
              child: const Text('Peruuta'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tasks[index]['name'] = editController.text; // Päivitä nimi
                  _tasks[index]['priority'] =
                      updatedPriority; // Päivitä prioriteetti
                  _taskBox.putAt(index, _tasks[index]); // Päivitä tietokanta
                });
                Navigator.of(context).pop(); // Sulje dialogi
              },
              child: const Text('Tallenna'),
            ),
          ],
        );
      },
    );
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _updateTask(index); // Muokkaa tehtävää
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _removeTask(index); // Poista tehtävä
                                },
                              ),
                            ],
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
