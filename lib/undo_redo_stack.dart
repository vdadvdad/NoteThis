import 'package:note_this/global_variables.dart';
import 'dart:developer' as developer;
import 'package:note_this/db_functions.dart';
import 'package:flutter/material.dart';
import 'package:note_this/json_db_classes.dart';

class RedoStack {
  static final List<StackAction> actions = [];

  static void addAction(StackAction action) {
    actions.add(action);
  }
  static StackAction? redo() {
    if (actions.isNotEmpty) {
      return actions.removeLast();
    }
    return null;
  }
  static void clear() {
    actions.clear();
  }
}

class StackAction<T> {
  T object;
  ObjectType objectType;
  StackAction(this.object, this.objectType);
}


class UndoAction extends Action<UndoIntent> {
  UndoAction();
  @override
  void invoke(covariant UndoIntent intent) {
    developer.log("Undo shortcut triggered via UndoAction!");
    developer.log("Current page ID: ${GlobalVariables.currentPageId}");
    developer.log("Current page lines: ${GlobalVariables.currentPage.lines.length}");
    if (GlobalVariables.currentPage.lines.isNotEmpty) {
      StackAction action = StackAction(GlobalVariables.currentPage.lines.last, ObjectType.point);
      RedoStack.addAction(action);
      GlobalVariables.currentPage.removeLast();
      deleteLastFromPageDb();
    } else {
      developer.log("No lines to undo");
    }
  }
}

class RedoAction extends Action<RedoIntent> {
  RedoAction();
  @override
  void invoke(covariant RedoIntent intent) {
    developer.log("Redo shortcut triggered via RedoAction!");
    StackAction? action = RedoStack.redo();
    if (action == null) {
      developer.log("No action to redo");
      return;
    }
    else if (action.objectType == ObjectType.point) {
      GlobalVariables.currentPage.addLine(action.object as DrawnLine);
    }
    addLineToPageDb(action.object as DrawnLine);
  }
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}
