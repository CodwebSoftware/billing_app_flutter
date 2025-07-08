// security_settings_screen.dart
import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  @override
  _SecuritySettingsScreenState createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;
  bool _activityAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACCOUNT SECURITY', style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                  // _SecurityTile(
                  //   icon: Icons.fingerprint_rounded,
                  //   iconColor: Colors.purple,
                  //   title: 'Biometric Authentication',
                  //   subtitle: 'Use fingerprint or face ID to log in',
                  //   trailing: Switch.adaptive(
                  //     value: _biometricEnabled,
                  //     onChanged: (value) => setState(() => _biometricEnabled = value),
                  //   ),
                  // ),
                  // Divider(height: 1, indent: 16),
                  // _SecurityTile(
                  //   icon: Icons.enhanced_encryption_rounded,
                  //   iconColor: Colors.blue,
                  //   title: 'Two-Factor Authentication',
                  //   subtitle: 'Add an extra layer of security',
                  //   trailing: Switch.adaptive(
                  //     value: _twoFactorEnabled,
                  //     onChanged: (value) => setState(() => _twoFactorEnabled = value),
                  //   ),
                  // ),
                  // Divider(height: 1, indent: 16),
                  _SecurityTile(
                    icon: Icons.password_rounded,
                    iconColor: Colors.orange,
                    title: 'Change Password',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen())),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text('SECURITY ALERTS', style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                  // _SecurityTile(
                  //   icon: Icons.security_rounded,
                  //   iconColor: Colors.green,
                  //   title: 'Activity Alerts',
                  //   subtitle: 'Get notified about suspicious activity',
                  //   trailing: Switch.adaptive(
                  //     value: _activityAlertsEnabled,
                  //     onChanged: (value) => setState(() => _activityAlertsEnabled = value),
                  //   ),
                  // ),
                  // Divider(height: 1, indent: 16),
                  _SecurityTile(
                    icon: Icons.devices_rounded,
                    iconColor: Colors.red,
                    title: 'Active Devices',
                    subtitle: 'View and manage logged-in devices',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveDevicesScreen())),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text('ADVANCED', style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                  _SecurityTile(
                    icon: Icons.vpn_key_rounded,
                    iconColor: Colors.teal,
                    title: 'Recovery Keys',
                    subtitle: 'Manage your account recovery options',
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 16),
                  _SecurityTile(
                    icon: Icons.delete_rounded,
                    iconColor: Colors.red,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account',
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('CANCEL', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // Delete account logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account deletion requested')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SecurityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Placeholder screens (would need actual implementation)
class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: Center(child: Text('Change Password Screen')),
    );
  }
}

class ActiveDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Active Devices')),
      body: Center(child: Text('Active Devices Screen')),
    );
  }
}