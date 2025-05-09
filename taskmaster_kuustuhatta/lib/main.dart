import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      home: const TaskCalendarPage(),
    );
  }
}

class TaskCalendarPage extends StatefulWidget {
  const TaskCalendarPage({super.key});

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  final Box _taskBox = Hive.box('tasks'); // Hive-tietokanta
  final TextEditingController _taskController = TextEditingController();
  int _selectedPriority = 1;

  List<Map<String, dynamic>> _tasks = []; // Tehtävälista

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Lataa tehtävät tietokannasta sovelluksen käynnistyessä
  }

  void _loadTasks() {
    final data = _taskBox.values.toList();
    setState(() {
      _tasks =
          data.map((task) {
            return Map<String, dynamic>.from(task as Map);
          }).toList();
    });
  }

  void _saveTasks() {
    _taskBox.clear(); // Tyhjennä tietokanta
    for (var task in _tasks) {
      _taskBox.add(task); // Tallenna jokainen tehtävä
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'name': _taskController.text,
          'done': false,
          'priority': _selectedPriority,
        });
        _taskController.clear();
        _selectedPriority = 1;
        _saveTasks(); // Tallenna muutokset tietokantaan
      });
    }
  }

  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
      _saveTasks(); // Tallenna muutokset tietokantaan
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks(); // Tallenna muutokset tietokantaan
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
                      updatedPriority = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Peruuta'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tasks[index]['name'] = editController.text;
                  _tasks[index]['priority'] = updatedPriority;
                  _saveTasks(); // Tallenna muutokset tietokantaan
                });
                Navigator.of(context).pop();
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
        title: const Text('Taskmaster - Kalenteri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Kalenterin otsikko
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tänään: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          // Tehtävien lista
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _tasks[index]['name'],
                    style: TextStyle(
                      decoration:
                          _tasks[index]['done']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none, // Yliviivaa tehty tehtävä
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
                      _toggleTaskDone(index); // Vaihda tehtävän tila
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _updateTask(index); // Muokkaa tehtävää
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
          // Tekstikenttä, prioriteetti ja nappi
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
