import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'json_db_classes.dart';
import 'dart:developer' as developer;
import 'dart:math';

class GlobalVariables{
  static ScrollController scrollController = ScrollController();
  static PagesModel pages = PagesModel();
  static int currentPageId = -1;
  static DrawnLineListModel currentPage = DrawnLineListModel([]);
  static Database? pagesDatabase;
  static Paint brush = Paint()
    ..color = Colors.black
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  static bool pagesPopulated = false;
  static NoteThisColors appColors = NoteThisColors();
  static PictureRecorder pictureRecorder = PictureRecorder();
  static Canvas canvas = Canvas(pictureRecorder);
  static ActionType actionType = ActionType.draw;
  static OnCanvasTextModel onCanvasText = OnCanvasTextModel();
  static bool darkMode = false;
}

class NoteThisColors extends ChangeNotifier {
  Color primaryColor = Colors.black;
  Color bgColor = Colors.blue[100]!;
  Color accentColor = Colors.blue[300]!;
  void setPrimaryColor(Color color) {
    primaryColor = color;
    developer.log("Primary color changed to: $color");
    notifyListeners();
  }
  void setBgColor(Color color) {
    bgColor = color;
    developer.log("Background color changed to: $color");
    notifyListeners();
  }
  void setAccentColor(Color color) {
    accentColor = color;
    developer.log("Accent color changed to: $color");
    notifyListeners();
  }
}


class PagesModel extends ChangeNotifier {
  List<Widget> pages = [];
  void addPage(Widget page) {
    pages.add(page);
    notifyListeners();
    developer.log("Notified about ${pages.last.toString()}");
  }
}
class DrawnLineListModel extends ChangeNotifier {
  List<DrawnLine> lines = [];
  bool isEmpty = true;
  bool isNotEmpty = false;
  int length = 0;
  double width = 0;
  double height = 0;

  void setLines(List<DrawnLine> lines) {
    developer.log("setLines called with ${lines.length} lines");
    this.lines = lines;
    isEmpty = lines.isEmpty;
    isNotEmpty = lines.isNotEmpty;
    length = lines.length;
    width = 0;
    height = 0;
    for (final line in lines) {
      if (line.points.isNotEmpty) {
        width = max(width, line.points.map((point) => point.x).reduce((a, b) => max(a, b)));
        height = max(height, line.points.map((point) => point.y).reduce((a, b) => max(a, b)));
      }
    }
    developer.log("setLines: isEmpty=$isEmpty, isNotEmpty=$isNotEmpty, length=$length");
    notifyListeners();
  }
  void removeLast() {
    lines.removeLast();
    length--;
    isNotEmpty = lines.isNotEmpty;
    notifyListeners();
  }

  void addLine(DrawnLine line) {
    lines.add(line);
    isEmpty = false;
    length += 1;  
    isNotEmpty = true;
    if (line.points.isNotEmpty) {
      width = max(width, line.points.map((point) => point.x).reduce((a, b) => max(a, b)));
      height = max(height, line.points.map((point) => point.y).reduce((a, b) => max(a, b)));
    }
    notifyListeners();
  }
  void clear() {
    developer.log("Clearing lines");
    lines.clear();
    isEmpty = true; 
    length = 0;
    isNotEmpty = false;
    width = 0;
    height = 0;
    notifyListeners();
  }
  
  DrawnLineListModel(this.lines);
}
enum ObjectType {
  point,
  text,
  image,
  color,
}
enum ActionType {
  draw,
  erase,
  text,
  photo,
  rectangle,
  circle,
  pointer,
}

class OnCanvasTextModel extends ChangeNotifier {
  List<Widget> textFields = [];
  void addTextField(Widget textField) {
    textFields.add(textField);
    notifyListeners();
  }
  void setTextFields(List<Widget> textFields) {
    this.textFields = textFields;
    notifyListeners();
  }
  void removeTextField(Widget textField) {
    textFields.remove(textField);
    notifyListeners();
  }
  void clear() {
    textFields.clear();
    notifyListeners();
  }
  OnCanvasTextModel();
}