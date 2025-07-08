import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
      pageController.nextPage(
        duration: 300.milliseconds,
        curve: Curves.ease,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}