import 'package:billing_app_flutter/dio/controllers/onboarding_controller.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:billing_app_flutter/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: (index) => controller.currentPage.value = index,
                children: const [
                  OnboardingPage(
                    title: 'Welcome to Our Software',
                    subtitle: 'Get started with your license activation',
                    image: 'assets/images/onboarding1.svg',
                    color: Colors.blue,
                  ),
                  OnboardingPage(
                    title: 'License Activation',
                    subtitle: 'Enter your license key to continue',
                    image: 'assets/images/onboarding2.svg',
                    color: Colors.green,
                  ),
                  OnboardingPage(
                    title: 'Ready to Go!',
                    subtitle: 'Start using the full features of our software',
                    image: 'assets/images/onboarding3.svg',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => AnimatedContainer(
                  duration: 300.milliseconds,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentPage.value == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: () {
                    if (controller.currentPage.value == 2) {
                      controller.completeOnboarding();
                      Get.offNamed(AppRoutes.licenseActivation);
                    } else {
                      controller.nextPage();
                    }
                  },
                  child: Text(
                    controller.currentPage.value == 2
                        ? 'Get Started'
                        : 'Next',
                  ),
                )),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}