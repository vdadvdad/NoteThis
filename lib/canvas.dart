import 'package:flutter/material.dart';
import 'global_variables.dart';
import 'dart:developer' as developer;

class CanvasPainter extends CustomPainter {
  final DrawnLineListModel linesModel;

  CanvasPainter(this.linesModel);
  
  @override
  void paint(Canvas canvas, Size size) {
    developer.log("CanvasPainter.paint called with ${linesModel.lines.length} lines");
    for (var line in linesModel.lines) {
      if (!line.isDisplayed) {
        developer.log("Skipping line - not displayed");
        continue;
      }
      if (line.points.isEmpty) {
        developer.log("Skipping line - no points");
        continue;
      }
      //developer.log("Drawing line with ${line.points.length} points");
      var path = Path();
      path.moveTo(line.points[0].x, line.points[0].y); // start at first point
      for (var point in line.points) {
        path.lineTo(point.x, point.y);
        Paint paint = Paint()
          ..color = Color.fromARGB(line.color[0], line.color[1], line.color[2], line.color[3])
          ..strokeWidth = point.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, paint);
        GlobalVariables.canvas.drawPath(path, paint);
        path = Path();
        path.moveTo(point.x, point.y); // start at last drawn point
      }
      
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}