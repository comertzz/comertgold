import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_model.dart';

class CryptoApiService {
  static const String _baseUrl = 'https://finance.truncgil.com/api';
  static const String _cryptoRatesEndpoint = '/crypto-currency-rates';

  Future<List<CryptoModel>> getCryptoPrices() async {
    try {
      print('Trunçgil Finance Crypto API\'den veri çekiliyor...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl$_cryptoRatesEndpoint'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Crypto Response Status: ${response.statusCode}');
      print('Crypto Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Crypto API Response Keys: ${jsonData.keys.toList()}');
        
        if (jsonData.containsKey('Rates')) {
          final Map<String, dynamic> rates = jsonData['Rates'];
          List<CryptoModel> cryptoList = [];
          
          rates.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                final tryPrice = _parsePrice(value['TRY_Price']);
                final usdPrice = _parsePrice(value['USD_Price']);
                
                // Sadece geçerli fiyatı olan crypto'ları ekle
                if (tryPrice != null && tryPrice > 0) {
                  final crypto = CryptoModel(
                    name: value['Name'] ?? key,
                    code: key,
                    usdPrice: usdPrice,
                    tryPrice: tryPrice,
                    selling: _parsePrice(value['Selling']),
                    change: value['Change']?.toString() ?? '0',
                    changePercent: value['Change'] != null ? '${value['Change']}%' : '0%',
                    time: jsonData['Meta_Data']?['Current_Date'] ?? '',
                    date: jsonData['Meta_Data']?['Update_Date'] ?? '',
                  );
                  cryptoList.add(crypto);
                  print('Crypto Eklenen: ${crypto.name} - TRY: ${crypto.tryPrice}');
                } else {
                  print('Crypto Filtrelenen (fiyat 0): ${value['Name'] ?? key}');
                }
              } catch (e) {
                print('Crypto veri parse hatası ($key): $e');
              }
            }
          });
          
          print('${cryptoList.length} crypto verisi çekildi');
          return cryptoList;
        } else {
          throw Exception('Crypto Rates verisi bulunamadı');
        }
      } else {
        print('Crypto API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Crypto API isteği başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Crypto veri çekme hatası: $e');
      throw Exception('Crypto veri çekme hatası: $e');
    }
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      String cleanValue = value.trim();
      if (cleanValue.contains(',') && cleanValue.contains('.')) {
        cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleanValue.contains(',')) {
        cleanValue = cleanValue.replaceAll(',', '.');
      }
      cleanValue = cleanValue.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  // Mock data için (API çalışmazsa)
  List<CryptoModel> getMockCryptoData() {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    return [
      CryptoModel(
        name: 'Bitcoin',
        code: 'BTC',
        usdPrice: 114145.0,
        tryPrice: 4641875.0,
        selling: 4641875.0,
        change: '-0.1',
        changePercent: '-0.1%',
        time: timeString,
        date: dateString,
      ),
      CryptoModel(
        name: 'Ethereum',
        code: 'ETH',
        usdPrice: 3633.39,
        tryPrice: 147834.0,
        selling: 147834.0,
        change: '2.0',
        changePercent: '2.0%',
        time: timeString,
        date: dateString,
      ),
      CryptoModel(
        name: 'Ripple',
        code: 'XRP',
        usdPrice: 3.0395,
        tryPrice: 123.59,
        selling: 123.59,
        change: '1.47',
        changePercent: '1.47%',
        time: timeString,
        date: dateString,
      ),
      CryptoModel(
        name: 'Tether',
        code: 'USDT',
        usdPrice: 0.999905,
        tryPrice: 40.67,
        selling: 40.67,
        change: '-0.01',
        changePercent: '-0.01%',
        time: timeString,
        date: dateString,
      ),
      CryptoModel(
        name: 'BNB',
        code: 'BNB',
        usdPrice: 759.31,
        tryPrice: 30875.0,
        selling: 30875.0,
        change: '0.35',
        changePercent: '0.35%',
        time: timeString,
        date: dateString,
      ),
      CryptoModel(
        name: 'Solana',
        code: 'SOL',
        usdPrice: 167.57,
        tryPrice: 6812.5,
        selling: 6812.5,
        change: '2.65',
        changePercent: '2.65%',
        time: timeString,
        date: dateString,
      ),
    ];
  }
} 