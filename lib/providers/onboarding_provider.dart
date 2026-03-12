import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;

  // Selections
  List<String> sleepGoals = [];
  List<String> sleepChallenges = [];
  List<String> preferredContent = [];
  TimeOfDay targetBedtime = const TimeOfDay(hour: 22, minute: 0);

  void setPage(int index) {
    currentPage = index;
    notifyListeners();
  }

  void nextPage() {
    focusNext();
  }
  
  void focusNext() {
      pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleGoal(String goal) {
    if (sleepGoals.contains(goal)) {
      sleepGoals.remove(goal);
    } else {
      sleepGoals.add(goal);
    }
    notifyListeners();
  }

  void toggleChallenge(String challenge) {
    if (sleepChallenges.contains(challenge)) {
      sleepChallenges.remove(challenge);
    } else {
      sleepChallenges.add(challenge);
    }
    notifyListeners();
  }

  void toggleContent(String content) {
    if (preferredContent.contains(content)) {
      preferredContent.remove(content);
    } else {
      preferredContent.add(content);
    }
    notifyListeners();
  }

  void setBedtime(TimeOfDay time) {
    targetBedtime = time;
    notifyListeners();
  }

  // Assuming you would save these to SharedPreferences/Firestore
  Future<void> completeOnboarding() async {
    await StorageService.setBool('has_completed_onboarding', true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
