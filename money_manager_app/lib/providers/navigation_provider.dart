import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void goToTab(int index) {
    if (index < 0 || index > 4) return;
    _currentIndex = index;
    notifyListeners();
  }
}
