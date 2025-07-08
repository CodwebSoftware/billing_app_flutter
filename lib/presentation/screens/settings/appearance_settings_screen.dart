// appearance_settings_screen.dart
import 'package:flutter/material.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  _AppearanceSettingsScreenState createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  bool _isDarkMode = false;
  String _selectedTheme = 'System';
  String _selectedFont = 'Inter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appearance'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THEME',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.blueGrey,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: Text('Dark Mode'),
                    value: _isDarkMode,
                    onChanged: (value) => setState(() => _isDarkMode = value),
                    secondary: Icon(Icons.dark_mode_rounded),
                  ),
                  Divider(height: 1, indent: 16),
                  RadioListTile<String>(
                    title: Text('System Default'),
                    value: 'System',
                    groupValue: _selectedTheme,
                    onChanged:
                        (value) =>
                            setState(() => _selectedTheme = value ?? 'System'),
                  ),
                  Divider(height: 1, indent: 16),
                  RadioListTile<String>(
                    title: Text('Light'),
                    value: 'Light',
                    groupValue: _selectedTheme,
                    onChanged:
                        (value) =>
                            setState(() => _selectedTheme = value ?? 'System'),
                  ),
                  Divider(height: 1, indent: 16),
                  RadioListTile<String>(
                    title: Text('Dark'),
                    value: 'Dark',
                    groupValue: _selectedTheme,
                    onChanged:
                        (value) =>
                            setState(() => _selectedTheme = value ?? 'System'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text(
              'FONT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.blueGrey,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Inter', style: TextStyle(fontFamily: 'Inter')),
                    value: 'Inter',
                    groupValue: _selectedFont,
                    onChanged:
                        (value) =>
                            setState(() => _selectedFont = value ?? 'Inter'),
                  ),
                  Divider(height: 1, indent: 16),
                  RadioListTile<String>(
                    title: Text(
                      'Roboto',
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    value: 'Roboto',
                    groupValue: _selectedFont,
                    onChanged:
                        (value) =>
                            setState(() => _selectedFont = value ?? 'Inter'),
                  ),
                  Divider(height: 1, indent: 16),
                  RadioListTile<String>(
                    title: Text(
                      'Open Sans',
                      style: TextStyle(fontFamily: 'OpenSans'),
                    ),
                    value: 'Open Sans',
                    groupValue: _selectedFont,
                    onChanged:
                        (value) =>
                            setState(() => _selectedFont = value ?? 'Inter'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text(
              'DISPLAY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.blueGrey,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Font Size'),
                    trailing: Text(
                      'Medium',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    title: Text('Display Density'),
                    trailing: Text(
                      'Default',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
