import 'package:flutter/material.dart';
import 'package:note_this/app_bar.dart';
import 'package:note_this/drawing_engine.dart';

class ContentWindow extends StatelessWidget {
  const ContentWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          DrawingEngine(),
          NoteThisAppBar(),
        ],
    );
  }
}