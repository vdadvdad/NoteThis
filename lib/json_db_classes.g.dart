// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_db_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonPoint _$JsonPointFromJson(Map<String, dynamic> json) => JsonPoint(
  (json['x'] as num).toDouble(),
  (json['y'] as num).toDouble(),
  (json['width'] as num).toDouble(),
);

Map<String, dynamic> _$JsonPointToJson(JsonPoint instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'width': instance.width,
};

DrawnLine _$DrawnLineFromJson(Map<String, dynamic> json) => DrawnLine(
  (json['points'] as List<dynamic>)
      .map((e) => JsonPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['color'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
)..isDisplayed = json['isDisplayed'] as bool;

Map<String, dynamic> _$DrawnLineToJson(DrawnLine instance) => <String, dynamic>{
  'points': instance.points.map((e) => e.toJson()).toList(),
  'color': instance.color,
  'isDisplayed': instance.isDisplayed,
};

JsonText _$JsonTextFromJson(Map<String, dynamic> json) => JsonText(
  (json['x'] as num).toDouble(),
  (json['y'] as num).toDouble(),
  json['text'] as String,
  (json['id'] as num).toInt(),
  (json['fontSize'] as num).toInt(),
  (json['color'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$JsonTextToJson(JsonText instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'text': instance.text,
  'id': instance.id,
  'fontSize': instance.fontSize,
  'color': instance.color,
};

JsonAnnotation _$JsonAnnotationFromJson(Map<String, dynamic> json) =>
    JsonAnnotation(
      json['text'] as String,
      (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$JsonAnnotationToJson(JsonAnnotation instance) =>
    <String, dynamic>{
      'text': instance.text,
      'coordinates': instance.coordinates,
    };
