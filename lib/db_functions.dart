import 'global_variables.dart';
import 'json_db_classes.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'drawing_engine.dart';
import 'dart:convert';

Future<void> addPageToDb(String name) async {
  final int id = await GlobalVariables.pagesDatabase!.insert('pages', {'name': name});
  GlobalVariables.pages.addPage(
    ElevatedButton(
      onPressed: () => loadPage(id),
      child: Text(name),
    )
  );
  await GlobalVariables.pagesDatabase!.execute('CREATE TABLE page_$id (id INTEGER PRIMARY KEY AUTOINCREMENT, object TEXT, type INTEGER)');
  developer.log("Created table page_$id");
  GlobalVariables.currentPageId = id;
}

Future<void> loadPage(int id) async {
  DrawingEngine.resetValues();
  developer.log("Loading page $id");
  final page = await GlobalVariables.pagesDatabase!.query("page_$id", where: "type = ${ObjectType.point.index}");
  developer.log("Found ${page.length} lines for page $id");
  developer.log("ObjectType.point.index = ${ObjectType.point.index}");
  GlobalVariables.currentPage.setLines(page.map((e) {
    if (e['object'] == null) {
      developer.log("No object found for page $id");
      return DrawnLine([], [0,0,0,0]);
    }
    developer.log("Loading line object: ${e['object']}");
    return DrawnLine.fromJson(jsonDecode(e['object'] as String) as Map<String, dynamic>);
  }).toList());
  final pageText = await GlobalVariables.pagesDatabase!.query("page_$id", where: "type = ${ObjectType.text.index}");
  GlobalVariables.onCanvasText.setTextFields(pageText.map((e) {
    if (e['object'] == null) {
      developer.log("No text object found for page $id");
      return DraggableTextField(
        initialX: 0,
        initialY: 0,
        text: "",
        id: 0,
      );
    }
    final textData = JsonText.fromJson(jsonDecode(e['object'] as String) as Map<String, dynamic>);
    return DraggableTextField(
      initialX: textData.x,
      initialY: textData.y,
      text: textData.text,
      id: textData.id,
    );
  }).toList());
  GlobalVariables.currentPageId = id;
  developer.log("Page loaded from database");
}

Future<void> changeTextInPageDb(JsonText text) async {
  await GlobalVariables.pagesDatabase!.update("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(text), 'type': ObjectType.text.index}, where: "id = ${text.id}");
  //developer.log("Text changed in database");
}

Future<void> addLineToPageDb(DrawnLine line) async {
  //developer.log("Adding line to database for page ${GlobalVariables.currentPageId}");
  //developer.log("Line JSON: ${jsonEncode(line)}");
  final result = await GlobalVariables.pagesDatabase!.insert("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(line), 'type': ObjectType.point.index});
  developer.log("Line added to database with id: $result");
}
Future<void> deleteLastFromPageDb() async {
  await GlobalVariables.pagesDatabase!.delete("page_${GlobalVariables.currentPageId}", where: "id=(SELECT MAX(id) from page_${GlobalVariables.currentPageId})",);
}
Future<void> addTextToPageDb(JsonText text) async {
  final result = await GlobalVariables.pagesDatabase!.insert("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(text), 'type': ObjectType.text.index});
  developer.log("Text added to database with id: $result");
}

Future<int> getLastId() async {
  final id = await GlobalVariables.pagesDatabase!.query("page_${GlobalVariables.currentPageId}", where: "id=(SELECT MAX(id) from page_${GlobalVariables.currentPageId})");
  if (id.isEmpty) {
    return 0;
  }
  return id[0]['id'] as int;
}