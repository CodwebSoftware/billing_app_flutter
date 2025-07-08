// notification_settings_screen.dart
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NOTIFICATION PREFERENCES', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            )),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _NotificationToggleTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Receive app notifications',
                    value: _pushEnabled,
                    onChanged: (value) => setState(() => _pushEnabled = value),
                  ),
                  Divider(height: 1, indent: 16),
                  _NotificationToggleTile(
                    icon: Icons.email_rounded,
                    title: 'Email Notifications',
                    subtitle: 'Receive email updates',
                    value: _emailEnabled,
                    onChanged: (value) => setState(() => _emailEnabled = value),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text('NOTIFICATION SETTINGS', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            )),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _NotificationToggleTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Sounds',
                    value: _soundEnabled,
                    onChanged: (value) => setState(() => _soundEnabled = value),
                  ),
                  Divider(height: 1, indent: 16),
                  _NotificationToggleTile(
                    icon: Icons.vibration_rounded,
                    title: 'Vibration',
                    value: _vibrationEnabled,
                    onChanged: (value) => setState(() => _vibrationEnabled = value),
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.notification_important_rounded, color: Colors.blue),
                    ),
                    title: Text('Notification Tone'),
                    subtitle: Text('Default'),
                    trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text('CUSTOM NOTIFICATIONS', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            )),
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
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.chat_rounded, color: Colors.green),
                    ),
                    title: Text('Messages'),
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.event_rounded, color: Colors.purple),
                    ),
                    title: Text('Events'),
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {},
                    ),
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

class _NotificationToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}