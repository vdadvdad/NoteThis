import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'pdf_export.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class ColorIntent extends Intent {
  const ColorIntent(this.colorIndex);
  final int colorIndex;
}

class PrintIntent extends Intent {
  const PrintIntent(this.context);
  final BuildContext context;
}

class SearchAction extends Action<SearchIntent> {
  SearchAction();
  @override
  void invoke(covariant SearchIntent intent) {
    developer.log("Search shortcut triggered via SearchAction!");
  }
}

class PrintAction extends Action<PrintIntent> {
  PrintAction();
  @override
  void invoke(covariant PrintIntent intent) {
    printDocument(intent.context);
  }
}

class ColorAction extends Action<ColorIntent> {
  ColorAction();
  @override
  void invoke(covariant ColorIntent intent) {
    developer.log("Color ${intent.colorIndex} shortcut triggered via ColorAction!");
  }
}