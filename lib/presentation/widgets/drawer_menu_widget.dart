import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/presentation/screens/appointment/appointment_booking_screen.dart';
import 'package:billing_app_flutter/presentation/screens/customer/customer_management_screen.dart';
import 'package:billing_app_flutter/presentation/screens/employee/employee_list_screen.dart';
import 'package:billing_app_flutter/presentation/screens/products/product_management_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entries_screen.dart';
import 'package:billing_app_flutter/presentation/screens/services/services_management_screen.dart';
import 'package:billing_app_flutter/presentation/screens/settings/settings_screen.dart';
import 'package:billing_app_flutter/presentation/widgets/drawer_list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerMenuWidget extends StatelessWidget {
  const DrawerMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor =
        isDarkMode ? theme.colorScheme.secondary : const Color(0xFF3B982C);

    return Drawer(
      width: 280,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.apartment,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Billing App",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Business Management",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Main Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuSection(
                  context,
                  title: "Master",
                  items: [
                    _MenuItem(
                      title: 'Customers',
                      icon: Icons.people_outline,
                      onTap:
                          () =>
                              _navigateTo(context, CustomerManagementScreen()),
                    ),
                    _MenuItem(
                      title: 'Employees',
                      icon: Icons.badge_outlined,
                      onTap: () => _navigateTo(context, EmployeeListScreen()),
                    ),
                    _MenuItem(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      onTap:
                          () => _navigateTo(context, ProductManagementScreen()),
                    ),
                    _MenuItem(
                      title: 'Services',
                      icon: Icons.miscellaneous_services_outlined,
                      onTap:
                          () =>
                              _navigateTo(context, ServicesManagementScreen()),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildMenuSection(
                  context,
                  title: "Sale",
                  items: [
                    _MenuItem(
                      title: 'Sale Entry',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, SaleEntriesScreen(customer: CustomerEntity())),
                    ),
                    _MenuItem(
                      title: 'Sale Order',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                    _MenuItem(
                      title: 'Sale Return',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildMenuSection(
                  context,
                  title: "Purchase",
                  items: [
                    _MenuItem(
                      title: 'Purchase Entry',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                    _MenuItem(
                      title: 'Purchase Order',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                    _MenuItem(
                      title: 'Purchase Return',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildMenuSection(
                  context,
                  title: "Operations",
                  items: [
                    _MenuItem(
                      title: 'Appointments',
                      icon: Icons.calendar_today_outlined,
                      onTap:
                          () =>
                          _navigateTo(context, AppointmentBookingScreen()),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                _buildMenuSection(
                  context,
                  title: "System",
                  items: [
                    _MenuItem(
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () => _navigateTo(context, SettingsScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Powered by Codweb",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android_outlined,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+91 9404124875",
                      style: TextStyle(color: accentColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map(
          (item) => DrawerListTileWidget(
            title: item.title,
            tap: item.onTap,
            svgSrc: '',
          ),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Scaffold.of(context).closeDrawer();
    Get.to(() => screen);
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItem({required this.title, required this.icon, required this.onTap});
}
