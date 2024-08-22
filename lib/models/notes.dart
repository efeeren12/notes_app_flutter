class Note{
  int? noteID;
  late int categoryID;
  late String noteTitle;
  late String noteContent;
  late String noteDate;
  late int notePriority;

  Note(this.categoryID, this.noteTitle, this.noteContent, this.noteDate, this.notePriority);

  Note.withID(this.noteID, this.categoryID, this.noteTitle, this.noteContent, this.noteDate, this.notePriority);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["noteID"] = noteID;
    map["categoryID"] = categoryID;
    map["noteTitle"] = noteTitle;
    map["noteContent"] = noteContent;
    map["noteDate"] = noteDate;
    map["notePriority"] = notePriority;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.noteID = map["noteID"];
    this.categoryID = map["categoryID"];
    this.noteTitle = map["noteTitle"];
    this.noteContent = map["noteContent"];
    this.noteDate = map["noteDate"];
    this.notePriority = map["notePriority"];
    }

    @override
  String toString() {
    return 'Note{noteID: $noteID, categoryID: $categoryID, noteTitle: $noteTitle, noteContent: $noteContent, noteDate: $noteDate, notePriority: $notePriority}';
  }
}