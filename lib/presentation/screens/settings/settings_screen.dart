// settings_screen.dart
import 'package:billing_app_flutter/presentation/screens/company/company_profile_screen.dart';
import 'package:billing_app_flutter/presentation/screens/settings/contact_us_screen.dart';
import 'package:billing_app_flutter/presentation/screens/settings/help_center_screen.dart';
import 'package:billing_app_flutter/presentation/screens/settings/notification_settings_screen.dart';
import 'package:billing_app_flutter/presentation/screens/settings/security_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _SettingsSection(
              title: 'Account',
              icon: Icons.person_rounded,
              children: [
                _SettingsTile(
                  title: 'Profile',
                  subtitle: 'Update your personal information',
                  icon: Icons.account_circle_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyProfileManagementScreen())),
                ),
                _SettingsTile(
                  title: 'Security',
                  subtitle: 'Password, 2FA, and more',
                  icon: Icons.lock_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SecuritySettingsScreen())),
                ),
              ],
            ),

            _SettingsSection(
              title: 'Preferences',
              icon: Icons.tune_rounded,
              children: [
                // _SettingsTile(
                //   title: 'Appearance',
                //   subtitle: 'Theme, font size, and layout',
                //   icon: Icons.palette_rounded,
                //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppearanceSettingsScreen())),
                // ),
                _SettingsTile(
                  title: 'Notifications',
                  subtitle: 'Manage your alerts',
                  icon: Icons.notifications_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsScreen())),
                ),
              ],
            ),

            _SettingsSection(
              title: 'Support',
              icon: Icons.help_rounded,
              children: [
                _SettingsTile(
                  title: 'Help Center',
                  subtitle: 'FAQs and guides',
                  icon: Icons.help_center_rounded,
                  onTap: () {
                    Get.to(HelpCenterScreen());
                  },
                ),
                _SettingsTile(
                  title: 'Contact Us',
                  subtitle: 'Get in touch with support',
                  icon: Icons.email_rounded,
                  onTap: () {
                    Get.to(ContactUsScreen());
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Version 1.0.0',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.titleSmall),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
      onTap: onTap,
    );
  }
}