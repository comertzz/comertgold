import 'package:flutter/material.dart';
import '../models/gold_model.dart';
import '../services/gold_api_service.dart';

class GoldProvider extends ChangeNotifier {
  final GoldApiService _apiService = GoldApiService();
  
  List<GoldModel> _goldData = [];
  bool _isLoading = false;
  String? _error;

  List<GoldModel> get goldData => _goldData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoldPrices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gerçek API'den veri çekmeyi dene
      print('API\'den veri çekiliyor...');
      _goldData = await _apiService.getGoldPrices();
      print('API\'den ${_goldData.length} veri çekildi');
    } catch (e) {
      print('API Hatası: $e');
      // API çalışmazsa mock data kullan
      _goldData = _apiService.getMockGoldData();
      _error = 'API bağlantısı kurulamadı, demo veriler gösteriliyor. Hata: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    fetchGoldPrices();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 