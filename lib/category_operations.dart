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
                onTap: () {},
              ),
            );
          },
        ),
      );
    }
    return Container();
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((mapWithCategories) {
      setState(() {
        allCategories = mapWithCategories.map<Category>((readMap) {
          return Category.fromMap(readMap as Map<String, dynamic>);
        }).toList();
      });
    });
  }
}
