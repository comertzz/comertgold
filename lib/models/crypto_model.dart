class CryptoModel {
  final String? name;
  final String? code;
  final double? usdPrice;
  final double? tryPrice;
  final double? selling;
  final String? change;
  final String? changePercent;
  final String? time;
  final String? date;

  CryptoModel({
    this.name,
    this.code,
    this.usdPrice,
    this.tryPrice,
    this.selling,
    this.change,
    this.changePercent,
    this.time,
    this.date,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
      name: json['Name'] ?? '',
      code: json['code'] ?? '',
      usdPrice: _parsePrice(json['USD_Price']),
      tryPrice: _parsePrice(json['TRY_Price']),
      selling: _parsePrice(json['Selling']),
      change: json['Change']?.toString() ?? '0',
      changePercent: json['Change'] != null ? '${json['Change']}%' : '0%',
      time: json['time'] ?? '',
      date: json['date'] ?? '',
    );
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'usdPrice': usdPrice,
      'tryPrice': tryPrice,
      'selling': selling,
      'change': change,
      'changePercent': changePercent,
      'time': time,
      'date': date,
    };
  }
}

class CryptoResponse {
  final Map<String, dynamic> metaData;
  final List<CryptoModel> rates;

  CryptoResponse({
    required this.metaData,
    required this.rates,
  });

  factory CryptoResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rates = json['Rates'] ?? {};
    final List<CryptoModel> cryptoList = [];

    rates.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final crypto = CryptoModel.fromJson(value);
        cryptoList.add(crypto);
      }
    });

    return CryptoResponse(
      metaData: json['Meta_Data'] ?? {},
      rates: cryptoList,
    );
  }
} 