import 'package:flutter/material.dart';
import 'package:note_this/undo_redo_stack.dart';
import 'global_variables.dart';
import 'color_options.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'intents.dart';
import 'settings.dart';

class NoteThisAppBar extends StatefulWidget implements PreferredSizeWidget {
  const NoteThisAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<NoteThisAppBar> createState() => _NoteThisAppBarState();
}

class _NoteThisAppBarState extends State<NoteThisAppBar> {
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      onShowFocusHighlight: (show) {
        developer.log("AppBar focus: $show");
      },
      actions: <Type, Action<Intent>>{
        UndoIntent: UndoAction(),
        RedoIntent: RedoAction(),
        PrintIntent: PrintAction(),
        SearchIntent: SearchAction(),
        ColorIntent: ColorAction(),
      },
      shortcuts: <LogicalKeySet, Intent>{
        // Standard shortcuts
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta): const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.meta, LogicalKeyboardKey.shift): const RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyP, LogicalKeyboardKey.meta): PrintIntent(context),
        LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.meta): const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyK, LogicalKeyboardKey.meta, LogicalKeyboardKey.numpad1): const ColorIntent(1),
      },
      child: ListenableBuilder(
        listenable: GlobalVariables.appColors,
        builder: (context, child) {
          developer.log("App bar ListenableBuilder triggered - bgColor: ${GlobalVariables.appColors.bgColor}");
          return Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: EdgeInsets.only(left: 10, right: 10),
          height: kToolbarHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: GlobalVariables.appColors.bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Column(
                            children: [
                              Icon(Icons.undo, color: GlobalVariables.appColors.primaryColor,),
                              Text("Undo", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),)],),
                          onPressed: Actions.handler<UndoIntent>(context, UndoIntent()),
                        )
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          icon: Column(
                            children: [
                            Icon(Icons.redo, color: GlobalVariables.appColors.primaryColor,),
                            Text("Redo", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),)],),
                        onPressed: Actions.handler<RedoIntent>(context, RedoIntent()),
                        )
                      ),
                      IconButton(
                        onPressed: () {Actions.handler<SearchIntent>(context, SearchIntent());},
                        icon: Column(
                          children: [
                            Icon(Icons.search, color: GlobalVariables.appColors.primaryColor,),
                            Text("Search", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      IconButton(
                        onPressed: () {Actions.handler<PrintIntent>(context, PrintIntent(context));},
                        icon: Column(
                          children: [
                            Icon(Icons.print, color: GlobalVariables.appColors.primaryColor,),
                            Text("Print", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      IconButton(
                        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));},
                        icon: Column(
                          children: [
                            Icon(Icons.settings, color: GlobalVariables.appColors.primaryColor,),
                            Text("Settings", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      IconButton(
                        onPressed: () {showMenu(context: context, position: RelativeRect.fromLTRB(0, 0, 0, 0), items: colorOptions(context));},
                        icon: Column(
                          children: [
                            Icon(Icons.colorize, color: GlobalVariables.appColors.primaryColor,),
                            Text("Color", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      Column(
                        children: [
                          Text("Size", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          Slider(
                            value: GlobalVariables.brush.strokeWidth,
                            onChanged: (value) {setState(() {GlobalVariables.brush.strokeWidth = value;});},
                            min: 1,
                            max: 50,
                            divisions: 100,
                            activeColor: GlobalVariables.appColors.primaryColor,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          GlobalVariables.actionType = ActionType.text;
                        },
                        icon: Column(
                          children: [
                            Icon(Icons.text_fields, color: GlobalVariables.appColors.primaryColor,),
                            Text("Text", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      IconButton(
                        onPressed: () {
                          GlobalVariables.actionType = ActionType.draw;
                        },
                        icon: Column(
                          children: [
                            Icon(Icons.draw, color: GlobalVariables.appColors.primaryColor,),
                            Text("Draw", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),
                      IconButton(
                        onPressed: () {
                          GlobalVariables.actionType = ActionType.pointer;
                        },
                        icon: Column(
                          children: [
                            Icon(Icons.navigation_outlined, color: GlobalVariables.appColors.primaryColor,),
                            Text("Pointer", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 10,),),
                          ],
                        )
                      ),                      
                    ],
                  ),
                );
              },
      ),
    );
  }
}