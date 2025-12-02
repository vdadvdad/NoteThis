import 'package:flutter/material.dart';
import 'global_variables.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final returnButton = IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.close),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [returnButton],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text("Dark Mode"),
              Switch(value: GlobalVariables.darkMode, onChanged: (value) {
                setState(() {
                  if (GlobalVariables.darkMode) {
                    GlobalVariables.appColors.setBgColor(Colors.grey[800]!);
                    GlobalVariables.appColors.setPrimaryColor(Colors.white);
                    GlobalVariables.appColors.setAccentColor(Colors.blue[700]!);
                  } else {
                    GlobalVariables.appColors.setBgColor(Colors.blue[100]!);
                    GlobalVariables.appColors.setPrimaryColor(Colors.black);
                    GlobalVariables.appColors.setAccentColor(Colors.blue[300]!);
                  }
                  GlobalVariables.darkMode = !GlobalVariables.darkMode;
                });
              }),
            ],
          ),
          Row(
            children: [
              Text("Background & Accent Color"),
              ColorPicker(
                pickerColor: GlobalVariables.appColors.accentColor,
                onColorChanged: (value) {
                  GlobalVariables.appColors.setAccentColor(value);
                  GlobalVariables.appColors.setBgColor(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}