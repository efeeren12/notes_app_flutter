import 'package:flutter/material.dart';
import 'package:notes_app_flutter/models/category.dart';
import 'package:notes_app_flutter/utils/database_helper.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Category> allCategories = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (allCategories.isEmpty) {
      allCategories = [];
      updateCategoryList();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategoriler"),
      ),
      body: ListView.builder(
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(allCategories[index].categoryTitle),
              trailing: const Icon(Icons.delete),
              leading: const Icon(Icons.category),
              onTap: () => _deleteCategory(allCategories[index].categoryID),
            ),
          );
        },
      ),
    );
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((mapWithCategoryList) {
      setState(() {
        allCategories = mapWithCategoryList;
      });
    });
  }

  _deleteCategory(int? categoryID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Kategori Sil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Kategoriyi sildiğinizde bu kategoriye ait notlar da silinecektir. Emin misiniz?"),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Vazgeç"),
                    ),
                    TextButton(
                      onPressed: () {
                        databaseHelper
                            .deleteCategory(categoryID!)
                            .then((deletedCategory) {
                          if (deletedCategory != 0) {
                            setState(() {
                              updateCategoryList();
                              Navigator.pop(context);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Kategori silindi")));
                          }
                        });
                      },
                      child: const Text("Sil",
                          style: TextStyle(color: Colors.red)),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
