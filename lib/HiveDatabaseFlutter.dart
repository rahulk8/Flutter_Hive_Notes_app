// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class Hivedatabaseflutter extends StatefulWidget {
  const Hivedatabaseflutter({super.key});

  @override
  State<Hivedatabaseflutter> createState() => _HivedatabaseflutterState();
}

class _HivedatabaseflutterState extends State<Hivedatabaseflutter> {
  var peopleBox = Hive.box('Box');
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Function for adding or updating notes
  void addOrUpdate({String? key}) {
    if (key != null) {
      final person = peopleBox.get(key);
      if (person != null) {
        _notesController.text = person['notes'] ?? '';
      }
    } else {
      _notesController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use the system theme
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15,
              top: 15
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _notesController,
                maxLines: null, // Allow unlimited lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Enter your notes here',
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white, // Adjust label text color based on theme
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black // Black text in light mode
                      : Colors.white, // White text in dark mode
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Background color based on theme
                ),
                onPressed: () {
                  final notes = _notesController.text;
                  final now = DateTime.now();
                  final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(now); // Format the date and time

                  if (key == null) {
                    final newKey =
                        DateTime.now().microsecondsSinceEpoch.toString();
                    peopleBox.put(newKey, {'notes': notes, 'date': formattedDateTime}); // Store formatted date and time
                  } else {
                    peopleBox.put(key, {'notes': notes, 'date': formattedDateTime}); // Update with formatted date and time
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  key == null ? "Add" : "Update",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // Function for delete operation
  void deleteOperation(String key) {
    peopleBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Set system theme
      theme: ThemeData.light().copyWith(
        // Define light theme
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light().copyWith(
          secondary: Colors.amber, // Set secondary color for buttons
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        // Define dark theme
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: Colors.amberAccent, // Set secondary color for buttons in dark mode
        ),
      ), 
      home: Scaffold(
        
        body: ValueListenableBuilder(
          valueListenable: peopleBox.listenable(),
          builder: (context, box, widget) {
            if (box.isEmpty) {
              return Center(
                child: Text(
                  'No Notes added yet',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black // Black text in light mode
                        : Colors.white, // White text in dark mode
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final key = box.keyAt(index).toString();
                final items = box.get(key);
                final noteDate = items['date'] ?? 'Unknown date'; // Retrieve date

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          items?['notes'] ?? 'Unknown',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black // Black text in light mode
                                : Colors.white, // White text in dark mode
                          ),
                        ),
                        subtitle: Text(
                          '$noteDate',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black // Darker text in light mode
                                : Colors.white, // Lighter text in dark mode
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => addOrUpdate(key: key),
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary, // Icon color based on theme
                              ),
                            ),
                            IconButton(
                              onPressed: () => deleteOperation(key),
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.primary, // Icon color based on theme
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => addOrUpdate(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
