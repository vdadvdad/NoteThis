import 'package:flutter/material.dart';
import 'global_variables.dart';
import 'db_functions.dart';
import 'package:sqflite/sqflite.dart';
import 'content_window.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

Future<void> populatePages(BuildContext context, Size size) async {
  if (GlobalVariables.pagesPopulated == true) {
    return;
  }
  GlobalVariables.pagesPopulated = true;
  GlobalVariables.pagesDatabase = await openDatabase(
    'pages.db',
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE pages (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
    },
  );
  final pagesList = await GlobalVariables.pagesDatabase!.query('pages');
  final pageButtons = <Widget>[];
  for (var page in pagesList) {
    pageButtons.add(
      GestureDetector(
        onSecondaryTap: () => _showPageContextMenu(context, page['id'] as int, page['name'] as String),
        child: TextButton(
          onPressed: () => loadPage(page['id'] as int), 
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(5),
            minimumSize: Size(MediaQuery.of(context).size.width * 0.2, MediaQuery.of(context).size.height * 0.1),
            overlayColor: GlobalVariables.appColors.accentColor,
            backgroundColor: (page['id'] == GlobalVariables.currentPageId) ? GlobalVariables.appColors.accentColor : GlobalVariables.appColors.bgColor,
          ),
          child: Text(page['name'] as String,
            style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 24, fontFamily: 'Roboto')),
        )
      )
    );
    GlobalVariables.pages.addPage(
      pageButtons.last
    );
  }
  pageButtons.add(
    ListenableBuilder(
      listenable: GlobalVariables.appColors,
      builder: (context, child) {
        return ElevatedButton(
            onPressed: () => addPageToDb("New page"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(size.width * 0.2, size.height * 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: GlobalVariables.appColors.primaryColor, width: 1),
              ),
            ),
            child: Text("Add new page", style: TextStyle(color: GlobalVariables.appColors.primaryColor, fontSize: 16,),),
          );
      },
    )
  );
  GlobalVariables.pages.addPage(
    pageButtons.last
  );
}

void _showPageContextMenu(BuildContext context, int pageId, String currentName) {
  showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(100, 100, 0, 0), // Position near cursor
    items: [
      PopupMenuItem<String>(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit),
            SizedBox(width: 8),
            Text('Rename Page'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Page', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value == 'rename') {
      _showRenameDialog(context, pageId, currentName);
    } else if (value == 'delete') {
      _showDeleteDialog(context, pageId, currentName);
    }
  });
}

void _showRenameDialog(BuildContext context, int pageId, String currentName) {
  final TextEditingController controller = TextEditingController(text: currentName);
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rename Page'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Page Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _renamePage(context, pageId, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: Text('Rename'),
          ),
        ],
      );
    },
  );
}

void _showDeleteDialog(BuildContext context, int pageId, String pageName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Page'),
        content: Text('Are you sure you want to delete "$pageName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deletePage(context, pageId);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void _renamePage(BuildContext context, int pageId, String newName) async {
  await GlobalVariables.pagesDatabase!.update(
    'pages',
    {'name': newName},
    where: 'id = ?',
    whereArgs: [pageId],
  );
  // Refresh the pages list
  _refreshPages(context);
}

void _deletePage(BuildContext context, int pageId) async {
  await GlobalVariables.pagesDatabase!.delete(
    'pages',
    where: 'id = ?',
    whereArgs: [pageId],
  );
  // Refresh the pages list
  _refreshPages(context);
}

void _refreshPages(BuildContext context) {
  // Clear current pages and repopulate
  GlobalVariables.pages.pages.clear();
  populatePages(context, MediaQuery.of(context).size);
  // This will trigger a rebuild and repopulate the pages
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'NoteThis'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    populatePages(context, size);
    return Scaffold(
      body: Row(
        children: [
          ListenableBuilder(
            listenable: GlobalVariables.appColors,
            builder: (context, child) {
              developer.log("Main container ListenableBuilder triggered - bgColor: ${GlobalVariables.appColors.bgColor}");
              return Container(
                width: size.width * 0.2,
                height: size.height,
                color: GlobalVariables.appColors.bgColor,
                key: ValueKey(GlobalVariables.appColors.bgColor), // Force rebuild
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ListenableBuilder(
                    listenable: GlobalVariables.pages,
                    builder: (context, child) {
                      return Column(
                        children: GlobalVariables.pages.pages,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ContentWindow(),
          ),
        ],
      ),
    );
  }
}
