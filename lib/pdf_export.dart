import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'global_variables.dart';
import 'dart:developer' as developer;

Future<void> printDocument(BuildContext context) async {
  final pdf = pw.Document();
  final totalPageNumber = (GlobalVariables.currentPage.height / PdfPageFormat.letter.height).ceil();
  for (int i = totalPageNumber - 1; i >= 0; i--) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (context) {
        return pw.Container(
          child: pw.CustomPaint(
            size: PdfPoint(GlobalVariables.currentPage.width, GlobalVariables.currentPage.height),
            painter: (canvas, size) {
            developer.log("Current size is ${size.x} x ${size.y}");
            developer.log("trying to add ${GlobalVariables.currentPage.lines.length} lines");
            developer.log("Letter page width is ${PdfPageFormat.letter.width}");
            developer.log("Current page height is ${GlobalVariables.currentPage.height}");
            for (final line in GlobalVariables.currentPage.lines) {
              developer.log("Line colors are ${line.color[0]} ${line.color[1]} ${line.color[2]} ${line.color[3]}");
              final color = PdfColor(
                line.color[1] / 255,
                line.color[2] / 255,
                line.color[3] / 255,
              );
              canvas.setStrokeColor(color);
              
              for (int j = 0; j < line.points.length - 1; j++) {
                canvas.setLineWidth(line.points[j].width);
                developer.log("Drawing line $j from ${line.points[j].x} ${GlobalVariables.currentPage.height - (line.points[j].y - i * PdfPageFormat.letter.height)} to ${line.points[j + 1].x} ${GlobalVariables.currentPage.height - (line.points[j + 1].y - i * PdfPageFormat.letter.height)}");
                canvas.drawLine(
                  line.points[j].x,
                  GlobalVariables.currentPage.height - line.points[j].y - i * PdfPageFormat.letter.height,
                  line.points[j + 1].x,
                  GlobalVariables.currentPage.height - line.points[j + 1].y - i * PdfPageFormat.letter.height,
                );
                canvas.strokePath();
              }
            }
          },
        ),
        );
      },
    ));
  }
  Printing.sharePdf(bytes: await pdf.save());
  Printing.layoutPdf(onLayout: (format) => pdf.save());
}