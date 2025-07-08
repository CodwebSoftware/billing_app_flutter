import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menu_bar/menu_bar.dart';

List<BarButton> menuBarButtons() {
  return [
    BarButton(
      text: const Text(
        'File',
        style: TextStyle(color: Colors.white),
      ),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () => print('Save'),
            text: const Text('Save'),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Save as'),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            text: const Text('Open File'),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Open Folder'),
          ),
          const MenuDivider(),
          MenuButton(
            text: const Text('Preferences'),
            icon: const Icon(Icons.settings),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  onTap: () {},
                  icon: const Icon(Icons.keyboard),
                  text: const Text('Shortcuts'),
                ),
                const MenuDivider(),
                MenuButton(
                  onTap: () {},
                  icon: const Icon(Icons.extension),
                  text: const Text('Extensions'),
                ),
                const MenuDivider(),
                MenuButton(
                  icon: const Icon(Icons.looks),
                  text: const Text('Change theme'),
                  submenu: SubMenu(
                    menuItems: [
                      MenuButton(
                        onTap: () {},
                        icon: const Icon(Icons.light_mode),
                        text: const Text('Light theme'),
                      ),
                      const MenuDivider(),
                      MenuButton(
                        onTap: () {},
                        icon: const Icon(Icons.dark_mode),
                        text: const Text('Dark theme'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            text: const Text('Exit'),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    ),
    BarButton(
      text: const Text(
        'Sales',
        style: TextStyle(color: Colors.white),
      ),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () => print('Save'),
            text: const Text('Sales Order'),

          ),
          MenuButton(
            onTap: () {
              Get.to(SaleEntryScreen(invoiceEntity: SaleEntryEntity()));
            },
            text: const Text('Sales Entry'),
            shortcutText: 'Ctrl+S',
            shortcut:
            const SingleActivator(LogicalKeyboardKey.keyS, control: true),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Sales Return'),
          ),
        ],
      ),
    ),
    BarButton(
      text: const Text(
        'Edit',
        style: TextStyle(color: Colors.white),
      ),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () {},
            text: const Text('Undo'),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Redo'),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            text: const Text('Cut'),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Copy'),
          ),
          MenuButton(
            onTap: () {},
            text: const Text('Paste'),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            text: const Text('Find'),
          ),
        ],
      ),
    ),
    BarButton(
      text: const Text(
        'Help',
        style: TextStyle(color: Colors.white),
      ),
      submenu: SubMenu(
        menuItems: [
          MenuButton(
            onTap: () {},
            text: const Text('Check for updates'),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            text: const Text('View License'),
          ),
          const MenuDivider(),
          MenuButton(
            onTap: () {},
            icon: const Icon(Icons.info),
            text: const Text('About'),
          ),
        ],
      ),
    ),
  ];
}