import 'package:flutter/material.dart';
import '../models/crypto_model.dart';
import '../services/crypto_api_service.dart';

class CryptoProvider extends ChangeNotifier {
  final CryptoApiService _apiService = CryptoApiService();
  List<CryptoModel> _cryptoData = [];
  bool _isLoading = false;
  String? _error;

  List<CryptoModel> get cryptoData => _cryptoData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCryptoPrices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('Crypto API\'den veri çekiliyor...');
      _cryptoData = await _apiService.getCryptoPrices();
      print('Crypto API\'den ${_cryptoData.length} veri çekildi');
    } catch (e) {
      print('Crypto API Hatası: $e');
      _cryptoData = _apiService.getMockCryptoData();
      _error = 'Crypto API bağlantısı kurulamadı, demo veriler gösteriliyor. Hata: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    fetchCryptoPrices();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 