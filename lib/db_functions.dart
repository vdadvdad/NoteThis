import 'global_variables.dart';
import 'json_db_classes.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'drawing_engine.dart';
import 'dart:convert';

/// Performs SQL query to add a new page to the database with the given [name].
/// Assigns [GlobalVariables.currentPageId] to the new page's id.
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
/// Based on [id], returns a list of [JsonAnnotation] objects.
/// Each object contains the text and the coordinates of the annotation.
/// This corresponds to OCR model's output for the corresponsiding rectangle.
Future<List<JsonAnnotation>> getPageAnnotation(int id) async { 
  final page = await GlobalVariables.pagesDatabase!.query("page_$id", where: "type = ${ObjectType.annotation.index}");
  final annotations = page.map((e) {
    return JsonAnnotation.fromJson(jsonDecode(e['object'] as String) as Map<String, dynamic>);
  }).toList();
  return annotations;
}
/// Loads the page with the given [id] into [GlobalVariables.currentPage].
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

/// Updates the text in the database for the given [text] object.
/// It takes text that already exists in the database, and updates it without removal.
Future<void> changeTextInPageDb(JsonText text) async {
  await GlobalVariables.pagesDatabase!.update("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(text), 'type': ObjectType.text.index}, where: "id = ${text.id}");
  //developer.log("Text changed in database");
}

/// Adds a new line to the database for the given [line] object.
/// 'line' is a [DrawnLine] object, that contains the points, color and stroke width.
/// Normally, this is part of handwriting/drawing.
Future<void> addLineToPageDb(DrawnLine line) async {
  //developer.log("Adding line to database for page ${GlobalVariables.currentPageId}");
  //developer.log("Line JSON: ${jsonEncode(line)}");
  final result = await GlobalVariables.pagesDatabase!.insert("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(line), 'type': ObjectType.point.index});
  developer.log("Line added to database with id: $result");
}

/// deletes the last line from the database for the given page.
/// This is used for undo functionality.
Future<void> deleteLastFromPageDb() async {
  await GlobalVariables.pagesDatabase!.delete("page_${GlobalVariables.currentPageId}", where: "id=(SELECT MAX(id) from page_${GlobalVariables.currentPageId})",);
}

/// adds a new text to the database for the given [text] object.
/// 'text' is a [JsonText] object, that contains the text, x, y, id, font size and color.
/// This is used for text input.
Future<void> addTextToPageDb(JsonText text) async {
  final result = await GlobalVariables.pagesDatabase!.insert("page_${GlobalVariables.currentPageId}", {'object': jsonEncode(text), 'type': ObjectType.text.index});
  developer.log("Text added to database with id: $result");
}

/// returns the last (max) id from the database for the given page
Future<int> getLastId() async {
  final id = await GlobalVariables.pagesDatabase!.query("page_${GlobalVariables.currentPageId}", where: "id=(SELECT MAX(id) from page_${GlobalVariables.currentPageId})");
  if (id.isEmpty) {
    return 0;
  }
  return id[0]['id'] as int;
}