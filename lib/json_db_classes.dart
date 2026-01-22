import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'json_db_classes.g.dart';
/// A point object, that contains the x, y and width of the point.
/// This object is used to represent a signular point in a line.
@JsonSerializable()
class JsonPoint {
  final double x;
  final double y;
  final double width;

  JsonPoint(this.x, this.y, this.width);

  factory JsonPoint.fromJson(Map<String, dynamic> json) => _$JsonPointFromJson(json);
  Map<String, dynamic> toJson() => _$JsonPointToJson(this);
}

/// A line object, that contains a list of points, color and stroke width.
/// Colors are represented as alpha, red, green, blue.
@JsonSerializable(explicitToJson: true)
class DrawnLine {
  List<JsonPoint> points = [];
  /// alpha, red, green, blue
  List<int> color = []; 
  bool isDisplayed = true;

  DrawnLine(this.points, this.color);
  DrawnLine.fromOffset(Offset point, Color color, double width)
  {
    points = [JsonPoint(point.dx, point.dy, width)];
    this.color = [(color.a * 255).round(), (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round()];
  }
  factory DrawnLine.fromJson(Map<String, dynamic> json) => _$DrawnLineFromJson(json);
  Map<String, dynamic> toJson() => _$DrawnLineToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonText {
  final double x;
  final double y;
  final String text;
  final int id;
  final int fontSize;
  /// alpha, red, green, blue
  final List<int> color; 

  JsonText(this.x, this.y, this.text, this.id, this.fontSize, this.color);
  factory JsonText.fromJson(Map<String, dynamic> json) => _$JsonTextFromJson(json);
  Map<String, dynamic> toJson() => _$JsonTextToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonAnnotation {
  final String text;
  /// x1, y1, x2, y2, corresponding to the top-left and bottom-right corners of the rectangle.
  final List<double> coordinates;

  JsonAnnotation(this.text, this.coordinates);
  factory JsonAnnotation.fromJson(Map<String, dynamic> json) => _$JsonAnnotationFromJson(json);
  Map<String, dynamic> toJson() => _$JsonAnnotationToJson(this);
}
