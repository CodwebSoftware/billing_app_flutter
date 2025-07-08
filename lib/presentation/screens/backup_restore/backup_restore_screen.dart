import 'package:flutter/material.dart';

class BackupRestoreScreen extends StatelessWidget {
  Future<void> _backupDatabase(context) async {
    try {
      // Call the backup function
      // await backupDatabase();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup completed successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreDatabase(context) async {
    try {
      // Call the restore function
      // await restoreDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore completed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  Future<void> _confirmBackup(context) async {
    bool confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Backup'),
            content: Text('Are you sure you want to back up your data?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Backup'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _backupDatabase(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup and Restore your data securely.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _backupDatabase(context);
              },
              child: Text('Backup Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _restoreDatabase(context);
              },
              child: Text('Restore Data'),
            ),
          ],
        ),
      ),
    );
  }
}
