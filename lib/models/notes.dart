class Note {
  int? noteID;
  late int categoryID;
  String categoryTitle = "Unknown";
  late String noteTitle;
  late String noteContent;
  late String noteDate;
  late int notePriority;

  Note(this.categoryID, this.noteTitle, this.noteContent, this.noteDate,
      this.notePriority);

  Note.withID(this.noteID, this.categoryID, this.noteTitle, this.noteContent,
      this.noteDate, this.notePriority);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["noteID"] = noteID;
    map["categoryID"] = categoryID;
    map["categoryTitle"] = categoryTitle;
    map["noteTitle"] = noteTitle;
    map["noteContent"] = noteContent;
    map["noteDate"] = noteDate;
    map["notePriority"] = notePriority;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    noteID = map["noteID"];
    categoryID = map["categoryID"];
    categoryTitle = map["categoryTitle"];
    noteTitle = map["noteTitle"];
    noteContent = map["noteContent"];
    noteDate = map["noteDate"];
    notePriority = map["notePriority"];
  }

  @override
  String toString() {
    return 'Note{noteID: $noteID, categoryID: $categoryID, noteTitle: $noteTitle, noteContent: $noteContent, noteDate: $noteDate, notePriority: $notePriority}';
  }
}
