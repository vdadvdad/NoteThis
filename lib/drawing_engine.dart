import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stylus_support/stylus_event.dart';
import 'canvas.dart';
import 'dart:developer' as developer;
import 'json_db_classes.dart';
import 'global_variables.dart';
import 'db_functions.dart';
import 'dart:io';
import 'undo_redo_stack.dart';
import 'package:stylus_support/stylus_support.dart';


List<int> colorToList(Color color) {
  return [(color.a * 255).round(), (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round()];
}

class DraggableTextField extends StatefulWidget {
  final double initialX;
  final double initialY;
  final String text;
  final int id;
  const DraggableTextField({
    super.key,
    required this.initialX,
    required this.initialY,
    required this.text,
    required this.id,
  });

  @override
  State<DraggableTextField> createState() => _DraggableTextFieldState();
}

class _DraggableTextFieldState extends State<DraggableTextField> {
  late double x;
  late double y;
  bool isReadOnly = true;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    x = widget.initialX;
    y = widget.initialY;
    controller = TextEditingController();
    controller.text = widget.text;
    addTextToPageDb(JsonText(x, y, widget.text, widget.id, 16, colorToList(GlobalVariables.brush.color)));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalVariables.scrollController,
      builder: (context, child) {
        return Positioned(
          left: x,
          top: y,
          child: SizedBox(
            width: 200,
            child: Draggable(
              feedback: Material(
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: controller,
                    readOnly: isReadOnly,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: controller,
                  readOnly: isReadOnly,
                  autofocus: true,
                  onTap: () {
                    setState(() {
                      isReadOnly = false;
                      GlobalVariables.actionType = ActionType.pointer;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      isReadOnly = true;
                      changeTextInPageDb(JsonText(x, y, controller.text, widget.id, 16, colorToList(GlobalVariables.brush.color)));
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              onDragEnd: (details) {
                setState(() {
                  x = details.offset.dx;
                  y = details.offset.dy;
                });
              },
            ),
          ),
        );
      },
    );
  }
}



class DrawingEngine extends StatefulWidget {
  const DrawingEngine({super.key});

  static void resetValues() {
    GlobalVariables.scrollController.jumpTo(0);
    GlobalVariables.currentPage.clear();
  }

  @override
  State<DrawingEngine> createState() => _DrawingEngineState();
}

class _DrawingEngineState extends State<DrawingEngine> {
  double stylusPressure = 0;
  StreamSubscription<StylusEvent>? stylusEventListener;
  @override 
  void initState() {
    super.initState();
    initStylus();
  }
  Future<void> initStylus() async {
    if (Platform.isMacOS) {
      await StylusSupport().setStylusMonitoringEnabled(true);
      stylusEventListener = StylusSupport().stylusEventStream.listen((event) {
        stylusPressure = event.pressure;
        developer.log("Stylus pressure: $stylusPressure");
      });
    } else {
      stylusPressure = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = GlobalVariables.currentPage;
    return /*FocusableActionDetector(
      autofocus: true,
      onShowFocusHighlight: (show) {
        developer.log("DrawingEngine focus: $show");
      },
      shortcuts: <LogicalKeySet, Intent>{
        // Standard shortcuts
        LogicalKeySet(LogicalKeyboardKey.undo): const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.redo): const RedoIntent(),
        // Platform-specific shortcuts
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control): const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyY, LogicalKeyboardKey.control): const RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta): const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta, LogicalKeyboardKey.shift): const RedoIntent(),
      },
      actions: <Type, Action<Intent>>{
        UndoIntent: UndoAction(),
        RedoIntent: RedoAction(),
      },
      child: */ Listener(
    onPointerDown: (details) {
      if (GlobalVariables.currentPageId == -1) {
        return;
      }
      if (GlobalVariables.actionType == ActionType.text) {
        GlobalVariables.onCanvasText.addTextField(
          DraggableTextField(
            initialX: details.localPosition.dx,
            initialY: details.localPosition.dy,
            text: "",
            id: (getLastId() as int) + 1,
          ),
        );
      }
      else if (GlobalVariables.actionType == ActionType.draw) {
        final point = details.localPosition;
        final offsetY = GlobalVariables.scrollController.offset;
        final pointWithOffset = Offset(point.dx, point.dy + offsetY);
        if (pointWithOffset.dy < 0 || pointWithOffset.dx < 0) {
          return; // ignore points that are above or to the left of the starting point
        }
        // change brush size based on pressure if input is a stylus
        // doesnt work on macos
        double brushSizeMultiplier = 1;
        developer.log("Kind: ${details.kind}");
        double pressure = details.pressure;
        developer.log("Pressure: ${details.pressure}");
        // MacOS plugin for stylus
        if (Platform.isMacOS) {
          pressure = stylusPressure;
        }
        //brushSizeMultiplier = log(pressure + 1) / log(2); // log base 2 of pressure
        brushSizeMultiplier = pressure;
        developer.log("Brush size multiplier: $brushSizeMultiplier");
        setState((){
          developer.log("Adding line to current page");
          currentPage.addLine(DrawnLine.fromOffset(pointWithOffset, GlobalVariables.brush.color, GlobalVariables.brush.strokeWidth * brushSizeMultiplier));
        });
      }
    },
    onPointerMove: (details) {
      if (GlobalVariables.currentPageId == -1) {
        return;
      }
      if (GlobalVariables.actionType != ActionType.draw) {
        return;
      }
      final point = details.localPosition;
      final offsetY = GlobalVariables.scrollController.offset;
      final pointWithOffset = Offset(point.dx, point.dy + offsetY);
      if (pointWithOffset.dy < 0 || pointWithOffset.dx < 0) {
        return; // ignore points that are above or to the left of the starting point
      }
      double brushSizeMultiplier = 1;
      double pressure = details.pressure;
      if (Platform.isMacOS) {
          pressure = stylusPressure;
        }
        //brushSizeMultiplier = log(pressure + 1) / log(2); // log base 2 of pressure
      brushSizeMultiplier = pressure;
      setState((){
        if (currentPage.isEmpty) {
          return; // incorrect state, should not happen
        }
        currentPage.lines[currentPage.lines.length - 1].points.add(JsonPoint(pointWithOffset.dx, pointWithOffset.dy, brushSizeMultiplier * GlobalVariables.brush.strokeWidth));
      });
    },
    onPointerUp: (details) {
      if (GlobalVariables.currentPageId == -1) {
        return;
      }
      if (GlobalVariables.actionType != ActionType.draw) {
        return;
      }
      if (currentPage.isNotEmpty) {
        developer.log("Saving line to database");
        addLineToPageDb(currentPage.lines[currentPage.length - 1]);
        RedoStack.clear();
      } else {
        developer.log("No line added to database. Something went wrong.");
      }
    },
    child: RepaintBoundary(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: GlobalVariables.scrollController,
            child: ListenableBuilder(
              listenable: GlobalVariables.currentPage,
              builder: (context, child) {
                return Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: GlobalVariables.currentPage.height + 200,
                  child: CustomPaint(
                        painter: CanvasPainter(currentPage),
                        child: ListenableBuilder(
                          listenable: GlobalVariables.onCanvasText,
                          builder: (context, child) {
                            return Stack(
                              children: GlobalVariables.onCanvasText.textFields,
                            );
                          }
                        )
                      ),
                  );
              },
            ),
        ),
      ),
    //)
  );
  }
}

