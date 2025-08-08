

class GoldModel {
  final String? name;
  final String? code;
  final double? buying;
  final double? selling;
  final String? time;
  final String? date;
  final String? change;
  final String? changePercent;

  GoldModel({
    this.name,
    this.code,
    this.buying,
    this.selling,
    this.time,
    this.date,
    this.change,
    this.changePercent,
  });

  factory GoldModel.fromJson(Map<String, dynamic> json) {
    // İsim field'ını kontrol et - API'de 'key' field'ı kullanılıyor
    final name = json['key'] ?? json['name'] ?? json['type'] ?? json['gold_type'] ?? json['title'] ?? 
                 json['goldName'] ?? json['gold_name'] ?? json['product'] ?? json['product_name'] ?? 
                 json['description'] ?? json['desc'] ?? json['label'] ?? json['text'];
    
    return GoldModel(
      name: name,
      code: json['code'] ?? json['symbol'] ?? json['short_name'] ?? json['shortName'] ?? 
            json['abbreviation'] ?? json['abbr'] as String?,
      buying: _parsePrice(json['buy'] ?? json['buying'] ?? json['buy_price'] ?? json['purchase']),
      selling: _parsePrice(json['sell'] ?? json['selling'] ?? json['sell_price'] ?? json['sale']),
      time: json['last_update'] ?? json['time'] ?? json['updated_time'] as String?,
      date: json['last_update'] ?? json['date'] ?? json['updated_date'] ?? json['last_date'] as String?,
      change: json['percent'] ?? json['change'] ?? json['price_change'] ?? json['difference'] as String?,
      changePercent: json['percent'] != null ? '${json['percent']}%' : 
                     json['changePercent'] ?? json['change_percent'] ?? json['percentage'] as String?,
    );
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Türkçe fiyat formatını parse et
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'buying': buying,
      'selling': selling,
      'time': time,
      'date': date,
      'change': change,
      'changePercent': changePercent,
    };
  }
}

class GoldResponse {
  final List<GoldModel>? data;
  final String? message;
  final bool? success;

  GoldResponse({
    this.data,
    this.message,
    this.success,
  });

  factory GoldResponse.fromJson(Map<String, dynamic> json) {
    return GoldResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => GoldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
      'success': success,
    };
  }
} 