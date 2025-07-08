import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/presentation/screens/company/company_profile_screen.dart';
import 'package:billing_app_flutter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isLoading = true;
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.deepPurple[400],
      end: Colors.deepPurple[700],
    ).animate(_animationController);
  }

  void _initializeApp() {
    // Schedule the check after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkRegistration();
    });

    // Set up window manager for Windows platform
    _setupWindowManager();
  }

  void _setupWindowManager() {
    if (GetPlatform.isWindows) {
      // Convert to maximized mode after 5 seconds
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          await windowManager.maximize();
        } catch (e) {
          debugPrint('Error maximizing window: $e');
        }
      });
    }
  }

  Future<void> _checkRegistration() async {
    try {
      _updateStatus('Checking company profile...');

      final CompanyProfileController companyProfileController = Get.find();
      await companyProfileController.getCompanyProfiles();

      if (companyProfileController.companyProfileEntities.isNotEmpty) {
        _updateStatus('Profile found, navigating to dashboard...');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Get.offAll(() => DashboardScreen());
        }
      } else {
        _updateStatus('Setting up company profile...');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          final result = await Get.to(() => const CompanyProfileManagementScreen());
          if (result == true && mounted) {
            Get.offAll(() => DashboardScreen());
          }
        }
      }
    } catch (e) {
      _updateStatus('Error occurred');
      debugPrint('Registration check error: $e');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to check registration. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Theme.of(context).colorScheme.onError,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _statusText = status;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedIcon(),
              const SizedBox(height: 30),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildProgressIndicator(),
              const SizedBox(height: 20),
              _buildStatusText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Billing Software',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          minHeight: 8,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _statusText,
        key: ValueKey(_statusText),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}