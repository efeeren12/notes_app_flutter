import 'package:flutter/material.dart';
import 'package:notes_app_flutter/category_operations.dart';
import 'package:notes_app_flutter/models/category.dart';
import 'package:notes_app_flutter/models/notes.dart';
import 'package:notes_app_flutter/note_detail.dart';
import 'package:notes_app_flutter/utils/database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue),
      home: const NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> allNotes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text("Kategoriler"),
                  onTap: () {
                    Navigator.pop(context);
                    _goToCategoriesPage(context);
                  },
                ))
              ];
            },
          ),
        ],
        title: const Center(
          child: Text("Not Sepeti"),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: "Kategori Ekle",
            heroTag: "categoryAdd",
            onPressed: () {
              addCategoryDialog(context);
            },
            mini: true,
            child: const Icon(Icons.add_circle),
          ),
          FloatingActionButton(
            tooltip: "Not Ekle",
            heroTag: "noteAdd",
            onPressed: () => _goToDetailPage(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: allNotes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _assignPriorityIcon(allNotes[index].notePriority),
                  title: Text(allNotes[index].noteTitle),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori : ",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  allNotes[index].categoryTitle,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi : ",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(
                                    allNotes[index]
                                            .noteDate
                                            .toString()
                                            .contains("CURRENT_TIMESTAMP")
                                        ? DateTime.now()
                                        : DateTime.tryParse(
                                                allNotes[index].noteDate) ??
                                            DateTime.now(),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "İçerik : ${allNotes[index].noteContent}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () =>
                                      _deleteNote(allNotes[index].noteID!),
                                  child: const Text(
                                    "SİL",
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    _updateNote(context, allNotes[index]);
                                  },
                                  child: const Text(
                                    "GÜNCELLE",
                                    style: TextStyle(color: Colors.green),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _refreshNotes() async {
    List<Note> notes = await databaseHelper.getNoteList();
    setState(() {
      allNotes = notes;
    });
  }

  void _goToDetailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetail(
          title: "Yeni Not",
        ),
      ),
    ).then((value) {
      if (value == true) {
        _refreshNotes();
      }
    });
  }

  void addCategoryDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String newCategoryName = "";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori ekle",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (newValue) {
                    newCategoryName = newValue ?? "";
                  },
                  decoration: const InputDecoration(
                    labelText: "Kategori adı",
                    border: OutlineInputBorder(),
                  ),
                  validator: (enteredCategoryName) {
                    if (enteredCategoryName!.length < 3) {
                      return "En az 3 karakter giriniz";
                    }
                    return null;
                  },
                ),
              ),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Vazgeç"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      databaseHelper
                          .addCategory(Category(newCategoryName))
                          .then((categoryID) {
                        if (categoryID > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Kategori eklendi"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  child: const Text("Ekle"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _updateNote(BuildContext context, Note note) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NoteDetail(title: "Notu Düzenle", noteToEdit: note)))
        .then((value) {
      if (value == true) {
        _refreshNotes();
      }
    });
  }

  _assignPriorityIcon(int notePriority) {
    switch (notePriority) {
      case 0:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade100,
          child: const Text(
            "AZ",
            style: TextStyle(color: Colors.white),
          ),
        );
      case 1:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade200,
          child: const Text("ORTA",
              style: TextStyle(color: Colors.white, fontSize: 14)),
        );
      case 2:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade700,
          child: const Text("ACİL", style: TextStyle(color: Colors.white)),
        );
    }
  }

  _deleteNote(int noteID) {
    databaseHelper.deleteNote(noteID).then((deletedNoteID) {
      if (deletedNoteID > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Not silindi"),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _refreshNotes();
        });
      }
    });
  }

  _goToCategoriesPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const Categories())).then(
      (value) => setState(
        () {},
      ),
    );
  }
}
