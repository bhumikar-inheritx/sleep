import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PremiumProvider extends ChangeNotifier {
  static const String _storageKey = 'is_premium';
  
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  PremiumProvider() {
    _loadState();
  }

  void _loadState() {
    _isPremium = StorageService.getBool(_storageKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> upgrade() async {
    _isPremium = true;
    await StorageService.setBool(_storageKey, true);
    notifyListeners();
  }

  Future<void> reset() async {
    _isPremium = false;
    await StorageService.setBool(_storageKey, false);
    notifyListeners();
  }
}
