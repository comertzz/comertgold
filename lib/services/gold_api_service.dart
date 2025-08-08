import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gold_model.dart';

class GoldApiService {
  // Trunçgil Finance API - Ücretsiz ve kotasız
  static const String _baseUrl = 'https://finance.truncgil.com/api';
  static const String _goldRatesEndpoint = '/gold-rates';

  Future<List<GoldModel>> getGoldPrices() async {
    try {
      print('Trunçgil Finance API\'den veri çekiliyor...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl$_goldRatesEndpoint'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('API Response Keys: ${jsonData.keys.toList()}');
        
        if (jsonData.containsKey('Rates')) {
          final Map<String, dynamic> rates = jsonData['Rates'];
          List<GoldModel> goldList = [];
          
          rates.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                final buying = _parsePrice(value['Buying']);
                final selling = _parsePrice(value['Selling']);
                
                // Sadece geçerli fiyatı olan altınları ekle
                if (buying != null && buying > 0) {
                  final gold = GoldModel(
                    name: value['Name'] ?? key,
                    code: key,
                    buying: buying,
                    selling: selling ?? buying * 1.02, // Eğer selling yoksa %2 spread ekle
                    time: jsonData['Meta_Data']?['Current_Date'] ?? '',
                    date: jsonData['Meta_Data']?['Update_Date'] ?? '',
                    change: value['Change']?.toString() ?? '0',
                    changePercent: value['Change'] != null ? '${value['Change']}%' : '0%',
                  );
                  goldList.add(gold);
                  print('Eklenen: ${gold.name} - Alış: ${gold.buying}');
                } else {
                  print('Filtrelenen (fiyat 0): ${value['Name'] ?? key}');
                }
              } catch (e) {
                print('Veri parse hatası ($key): $e');
              }
            }
          });
          
          print('${goldList.length} altın verisi çekildi');
          return goldList;
        } else {
          throw Exception('Rates verisi bulunamadı');
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API isteği başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
      throw Exception('Veri çekme hatası: $e');
    }
  }

  // Geçmiş veriler için endpoint'leri dene
  Future<List<GoldModel>> getHistoricalPrices(String period) async {
    // Trunçgil Finance API'si şu anda geçmiş veri sağlamıyor
    // Bu yüzden simüle edilmiş veriler döndürüyoruz
    print('Geçmiş veriler simüle ediliyor: $period');
    
    // Simüle edilmiş geçmiş veriler
    List<GoldModel> historicalData = [];
    final now = DateTime.now();
    
    switch (period) {
      case '1G':
        // 24 saatlik veri
        for (int i = 23; i >= 0; i--) {
          final time = now.subtract(Duration(hours: i));
          historicalData.add(GoldModel(
            name: 'Gram Altın',
            buying: 2150.0 + (i % 6 - 3) * 5.0,
            selling: 2155.0 + (i % 6 - 3) * 5.0,
            time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            date: '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}',
            change: (i % 6 - 3) > 0 ? '+${(i % 6 - 3) * 5.0}' : '${(i % 6 - 3) * 5.0}',
            changePercent: '${((i % 6 - 3) * 5.0 / 2150.0 * 100).toStringAsFixed(2)}%',
          ));
        }
        break;
      case '1H':
        // 7 günlük veri
        for (int i = 6; i >= 0; i--) {
          final time = now.subtract(Duration(days: i));
          historicalData.add(GoldModel(
            name: 'Gram Altın',
            buying: 2150.0 + (i % 4 - 2) * 10.0,
            selling: 2155.0 + (i % 4 - 2) * 10.0,
            time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            date: '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}',
            change: (i % 4 - 2) > 0 ? '+${(i % 4 - 2) * 10.0}' : '${(i % 4 - 2) * 10.0}',
            changePercent: '${((i % 4 - 2) * 10.0 / 2150.0 * 100).toStringAsFixed(2)}%',
          ));
        }
        break;
      case '1A':
        // 30 günlük veri (3 günde bir)
        for (int i = 29; i >= 0; i -= 3) {
          final time = now.subtract(Duration(days: i));
          historicalData.add(GoldModel(
            name: 'Gram Altın',
            buying: 2150.0 + (i % 10 - 5) * 15.0,
            selling: 2155.0 + (i % 10 - 5) * 15.0,
            time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            date: '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}',
            change: (i % 10 - 5) > 0 ? '+${(i % 10 - 5) * 15.0}' : '${(i % 10 - 5) * 15.0}',
            changePercent: '${((i % 10 - 5) * 15.0 / 2150.0 * 100).toStringAsFixed(2)}%',
          ));
        }
        break;
      case '1Y':
        // 12 aylık veri
        for (int i = 11; i >= 0; i--) {
          final time = now.subtract(Duration(days: i * 30));
          historicalData.add(GoldModel(
            name: 'Gram Altın',
            buying: 2150.0 + (i % 6 - 3) * 50.0,
            selling: 2155.0 + (i % 6 - 3) * 50.0,
            time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            date: '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}',
            change: (i % 6 - 3) > 0 ? '+${(i % 6 - 3) * 50.0}' : '${(i % 6 - 3) * 50.0}',
            changePercent: '${((i % 6 - 3) * 50.0 / 2150.0 * 100).toStringAsFixed(2)}%',
          ));
        }
        break;
    }
    
    return historicalData;
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // String'den sayısal değeri çıkar
      String cleanValue = value.trim();
      
      // Nokta ve virgülü doğru şekilde işle
      if (cleanValue.contains(',') && cleanValue.contains('.')) {
        // "3.986,22" formatı - nokta binlik ayırıcı, virgül ondalık ayırıcı
        cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleanValue.contains(',')) {
        // Sadece virgül varsa ondalık ayırıcı olabilir
        cleanValue = cleanValue.replaceAll(',', '.');
      }
      
      // Sadece sayıları al
      cleanValue = cleanValue.replaceAll(RegExp(r'[^\d.]'), '');
      
      return double.tryParse(cleanValue);
    }
    return null;
  }

  // Mock data için (API çalışmazsa)
  List<GoldModel> getMockGoldData() {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    return [
      GoldModel(
        name: 'Gram Altın',
        code: 'GRA',
        buying: 2150.50,
        selling: 2155.75,
        time: timeString,
        date: dateString,
        change: '+5.25',
        changePercent: '+0.24%',
      ),
      GoldModel(
        name: 'Çeyrek Altın',
        code: 'QAU',
        buying: 8600.00,
        selling: 8620.00,
        time: timeString,
        date: dateString,
        change: '+20.00',
        changePercent: '+0.23%',
      ),
      GoldModel(
        name: 'Yarım Altın',
        code: 'HAU',
        buying: 17200.00,
        selling: 17240.00,
        time: timeString,
        date: dateString,
        change: '+40.00',
        changePercent: '+0.23%',
      ),
      GoldModel(
        name: 'Tam Altın',
        code: 'FAU',
        buying: 34400.00,
        selling: 34480.00,
        time: timeString,
        date: dateString,
        change: '+80.00',
        changePercent: '+0.23%',
      ),
      GoldModel(
        name: 'Cumhuriyet Altını',
        code: 'CAU',
        buying: 34400.00,
        selling: 34480.00,
        time: timeString,
        date: dateString,
        change: '+80.00',
        changePercent: '+0.23%',
      ),
      GoldModel(
        name: 'Ata Altın',
        code: 'AAU',
        buying: 34400.00,
        selling: 34480.00,
        time: timeString,
        date: dateString,
        change: '+80.00',
        changePercent: '+0.23%',
      ),
    ];
  }
} 