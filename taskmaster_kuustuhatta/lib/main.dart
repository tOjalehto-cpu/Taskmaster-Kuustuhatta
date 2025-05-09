import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // Käynnistetään sovellus
  // runApp() on Flutterin tapa käynnistää sovellus ja näyttää sen käyttöliittymä.
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
  final List<Map<String, dynamic>> _tasks =
      []; // Lista tehtäville (tehtävä + tila)
  final TextEditingController _taskController =
      TextEditingController(); // Tekstikentän ohjain

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'name': _taskController.text,
          'done': false,
        }); // Lisää tehtävä ja tila
        _taskController.clear(); // Tyhjennä tekstikenttä
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

  void _updateTask(int index) {
    // Näytä dialogi tehtävän muokkaamiseksi
    final TextEditingController editController =
        TextEditingController(text: _tasks[index]['name']); // Esitäytetty tekstikenttä
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Muokkaa tehtävää'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Tehtävän nimi',
              border: OutlineInputBorder(),
            ),
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
                  _tasks[index]['name'] = editController.text; // Päivitä tehtävän nimi
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
          // Tekstikenttä ja nappi
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
                ElevatedButton(onPressed: _addTask, child: const Text('Lisää')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
