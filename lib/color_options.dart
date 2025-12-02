import 'package:flutter/material.dart';
import 'global_variables.dart';

List<PopupMenuItem> colorOptions(BuildContext context) {
  final colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
  ];
  return [
    PopupMenuItem(
      child: SizedBox(
        width: 120,
        height: 80,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          shrinkWrap: true,
          children: colors.map((color) => IconButton(
            onPressed: () {
              GlobalVariables.brush.color = color;
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.square, color: color, size: 24),
          )).toList(),
        ),
      ),
    ),
  ];
}