import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Tämä widget näyttää valitun päivän tehtävät ja mahdollistaa niiden hallinnan.
class TaskCalendarPage extends StatefulWidget {
  final DateTime selectedDate; // Valittu päivämäärä

  const TaskCalendarPage({super.key, required this.selectedDate});

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

// Tämä luokka hallitsee tehtävänäkymän tilaa.
class _TaskCalendarPageState extends State<TaskCalendarPage> {
  final Box _taskBox = Hive.box(
    'tasks',
  ); // Hive-tietokanta, jossa tehtävät tallennetaan
  final TextEditingController _taskController =
      TextEditingController(); // Tekstikentän ohjain
  List<Map<String, dynamic>> _tasks = []; // Lista tehtävistä
  int _selectedPriority = 1; // Oletusprioriteetti uusille tehtäville

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Lataa tehtävät tietokannasta, kun näkymä avataan
  }

  // Lataa tietokannasta valitun päivän tehtävät
  void _loadTasks() {
    final data = _taskBox.values.toList(); // Hae kaikki tietokannan arvot
    final selectedDateString =
        widget.selectedDate.toIso8601String().split(
          'T',
        )[0]; // Päivämäärä muodossa "YYYY-MM-DD"

    setState(() {
      _tasks =
          data
              .map(
                (task) => Map<String, dynamic>.from(task as Map),
              ) // Muunna tietokannan tiedot Map-muotoon
              .where(
                (task) => task['date'] == selectedDateString,
              ) // Suodata valitun päivän tehtävät
              .toList();
    });
  }

  // Lisää uusi tehtävä tietokantaan
  void _saveTask(Map<String, dynamic> task) {
    _taskBox.add(task); // Lisää tehtävä tietokantaan
  }

  // Lisää uusi tehtävä listaan ja tietokantaan
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = {
        'name': _taskController.text, // Tehtävän nimi
        'done': false, // Tehtävän tila (ei tehty)
        'priority': _selectedPriority, // Tehtävän prioriteetti
        'date':
            widget.selectedDate.toIso8601String().split(
              'T',
            )[0], // Tehtävän päivämäärä
      };

      setState(() {
        _tasks.add(newTask); // Lisää tehtävä listaan
        _saveTask(newTask); // Tallenna tehtävä tietokantaan
        _taskController.clear(); // Tyhjennä tekstikenttä
        _selectedPriority = 1; // Palauta prioriteetti oletukseen
      });
    }
  }

  // Vaihda tehtävän tila (tehty/ei tehty)
  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done']; // Vaihda tila
      _taskBox.putAt(index, _tasks[index]); // Päivitä tietokanta
    });
  }

  // Poista tehtävä listasta ja tietokannasta
  void _removeTask(int index) {
    setState(() {
      _taskBox.deleteAt(index); // Poista tehtävä tietokannasta
      _tasks.removeAt(index); // Poista tehtävä listasta
    });
  }

  // Muokkaa olemassa olevaa tehtävää
  void _updateTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: _tasks[index]['name'], // Aseta nykyinen nimi tekstikenttään
    );
    int updatedPriority = _tasks[index]['priority']; // Nykyinen prioriteetti

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Muokkaa tehtävää'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller:
                    editController, // Tekstikenttä tehtävän nimen muokkaamiseen
                decoration: const InputDecoration(
                  labelText: 'Tehtävän nimi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: updatedPriority, // Nykyinen prioriteetti
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
          'Tehtävät: ${widget.selectedDate.toLocal().toString().split(' ')[0]}', // Näyttää valitun päivän otsikossa
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
                        'Ei tehtäviä valitulle päivälle.', // Näytetään, jos tehtäviä ei ole
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _tasks.length, // Tehtävien määrä
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _tasks[index]['name'], // Tehtävän nimi
                            style: TextStyle(
                              decoration:
                                  _tasks[index]['done']
                                      ? TextDecoration
                                          .lineThrough // Yliviivaa tehty tehtävä
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
                            value: _tasks[index]['done'], // Tehtävän tila
                            onChanged: (value) {
                              if (value != null) {
                                _toggleTaskDone(index); // Vaihda tila
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
                    controller:
                        _taskController, // Tekstikenttä uuden tehtävän lisäämiseen
                    decoration: const InputDecoration(
                      labelText: 'Lisää uusi tehtävä',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedPriority, // Valittu prioriteetti
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
                ElevatedButton(
                  onPressed: _addTask, // Lisää uusi tehtävä
                  child: const Text('Lisää'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
