import 'package:flutter/material.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
      body: const Notes(),
    );
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

  _goToDetailPage(BuildContext context) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => NoteDetail(title: "Yeni Not")))
        .then((value) => setState(() {}));
  }
}

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> allNotes = [];
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    allNotes = [];
    databaseHelper = DatabaseHelper();
    databaseHelper.getNotes().then((mapListWithNotes) {
      for (Map<dynamic, dynamic> map in mapListWithNotes) {
        allNotes.add(Note.fromMap(map as Map<String, dynamic>));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseHelper.getNoteList(),
        builder: (context, AsyncSnapshot<List<Note>> snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            allNotes = snapShot.data ?? [];

            return ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(allNotes[index].noteTitle),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Column(
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
                                  databaseHelper.dateFormat(allNotes[index]
                                          .noteDate
                                          .toString()
                                          .contains("CURRENT_TIMESTAMP")
                                      ? DateTime.now()
                                      : DateTime.tryParse(
                                              allNotes[index].noteDate) ??
                                          DateTime.now()),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
