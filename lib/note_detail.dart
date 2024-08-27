import 'package:flutter/material.dart';
import 'package:notes_app_flutter/models/category.dart';
import 'package:notes_app_flutter/models/notes.dart';
import 'package:notes_app_flutter/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String title;
  Note? noteToEdit;

  NoteDetail({super.key, required this.title, this.noteToEdit});

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();
  List<Category> allCategories = [];
  late DatabaseHelper databaseHelper;
  int? selectedCategoryID = 0;
  int selectedPriority = 1;
  late String noteTitle, noteContent;
  static final _priority = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategories().then((mapListWithCategory) {
      setState(() {
        allCategories = mapListWithCategory
            .map((readMap) => Category.fromMap(readMap as Map<String, dynamic>))
            .toList();
        if (allCategories.isNotEmpty) {
          selectedCategoryID = allCategories[0].categoryID; // Default selection
        }
      });
      if(widget.noteToEdit != null){
        selectedCategoryID = widget.noteToEdit!.categoryID;
        selectedCategoryID = widget.noteToEdit!.notePriority;
      }else{
        selectedCategoryID = 1;
        selectedPriority = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: (Text(widget.title)),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Kategori :",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      items: createCategoryItems(),
                      value: selectedCategoryID,
                      onChanged: (selectedID) {
                        setState(() {
                          selectedCategoryID = selectedID!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.noteToEdit != null
                    ? widget.noteToEdit!.noteTitle
                    : "",
                validator: (text) {
                  if (text!.length < 3) {
                    return "En az 3 karakter giriniz";
                  }
                },
                onSaved: (text) {
                  noteTitle = text!;
                },
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: "Not başlığını giriniz",
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.noteToEdit != null
                    ? widget.noteToEdit!.noteContent
                    : "",
                onSaved: (text) {
                  noteContent = text!;
                },
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: "Not içeriğini giriniz",
                  labelText: "İçerik",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Öncelik :",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      items: _priority.map((priority) {
                        return DropdownMenuItem<int>(
                          value: _priority.indexOf(priority),
                          child: Text(
                            priority,
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      }).toList(),
                      value: selectedPriority,
                      onChanged: (selectedPriorityID) {
                        setState(() {
                          selectedPriority = selectedPriorityID!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade200),
                  child: const Text("Vazgeç"),
                ),
                const SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      var now = DateTime.now();
                      if(widget.noteToEdit == null){
                        databaseHelper
                          .addNote(Note(selectedCategoryID!, noteTitle,
                              noteContent, now.toString(), selectedPriority))
                          .then((savedNoteID) {
                        if (savedNoteID != 0) {
                          Navigator.pop(context, true);
                        }
                      });
                      }else{
                        databaseHelper
                          .updateNote(Note.withID(widget.noteToEdit!.noteID, selectedCategoryID!, noteTitle,
                              noteContent, now.toString(), selectedPriority))
                          .then((savedNoteID) {
                        if (savedNoteID != 0) {
                          Navigator.pop(context, true);
                        }
                      });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade200),
                  child: const Text("Kaydet"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>>? createCategoryItems() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(
                category.categoryTitle,
                style: const TextStyle(fontSize: 24),
              ),
            ))
        .toList();
  }
}
