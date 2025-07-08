import 'package:billing_app_flutter/app_bindings.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:billing_app_flutter/presentation/routes/app_pages.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize core dependencies
    await _initializeCore();

    // Initialize ObjectBox
    final objectBox = await ObjectBoxes.create();

    // Initialize platform-specific configurations
    await _initializePlatformConfigurations();

    // Launch the app
    runApp(BillingApp(objectBox: objectBox));
  } catch (e) {
    // Handle initialization errors gracefully
    debugPrint('App initialization error: $e');
    runApp(const ErrorApp());
  }
}

Future<void> _initializeCore() async {
  // Set up error handling for the app
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const Material(
        child: Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    };
  }
}

Future<void> _initializePlatformConfigurations() async {
  if (Platform.isWindows) {
    await _initializeWindowsConfiguration();
  } else if (Platform.isIOS || Platform.isAndroid) {
    await _initializeMobileConfiguration();
  }
}

Future<void> _initializeWindowsConfiguration() async {
  try {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(600.0, 400.0),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(400.0, 300.0),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (e) {
    debugPrint('Error initializing Windows configuration: $e');
  }
}

Future<void> _initializeMobileConfiguration() async {
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Error setting mobile orientation: $e');
  }
}

class BillingApp extends StatelessWidget {
  final ObjectBoxes objectBox;

  const BillingApp({super.key, required this.objectBox});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing Software',
      initialBinding: AppBindings(objectBox),
      theme: _buildLightTheme(),
      darkTheme: _buildLightTheme(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.app,
      getPages: AppPages.pages,
      // Add global error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing Software - Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please restart the application',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}