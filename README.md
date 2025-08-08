# Altın Mobil Uygulaması

Modern ve kullanıcı dostu bir altın fiyat takip uygulaması. RapidAPI entegrasyonu ile gerçek zamanlı altın fiyatlarını gösterir.

## Özellikler

- 🏆 **Modern UI/UX**: Material Design 3 ile modern arayüz
- 📊 **Gerçek Zamanlı Veriler**: RapidAPI entegrasyonu
- 🔄 **Pull-to-Refresh**: Aşağı çekerek verileri yenileme
- ⚡ **Hızlı Yükleme**: Shimmer loading animasyonları
- 📱 **Responsive**: Tüm ekran boyutlarına uyumlu
- 🎨 **Altın Teması**: Amber renk paleti

## Teknolojiler

- **Flutter**: 3.8.1+
- **Provider**: State management
- **Go Router**: Navigation
- **HTTP**: API istekleri
- **Shimmer**: Loading animasyonları

## Kurulum

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd comert_gold
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## API Konfigürasyonu

API anahtarını `lib/services/gold_api_service.dart` dosyasında güncelleyin:

```dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
static const String _host = 'YOUR_HOST_HERE';
```

## Proje Yapısı

```
lib/
├── models/
│   └── gold_model.dart          # Altın veri modeli
├── providers/
│   └── gold_provider.dart       # State management
├── screens/
│   └── home_screen.dart         # Ana sayfa
├── services/
│   └── gold_api_service.dart    # API servisi
├── widgets/
│   └── gold_card.dart           # Altın kartı widget'ı
└── main.dart                    # Ana uygulama
```

## Özellikler Detayı

### Ana Sayfa
- Altın fiyatlarının listesi
- Alış/satış fiyatları
- Değişim oranları
- Zaman bilgileri

### Loading States
- Shimmer animasyonları
- Hata durumları
- Boş veri durumları

### API Entegrasyonu
- RapidAPI bağlantısı
- Hata yönetimi
- Mock data fallback

## Geliştirme

### Yeni Özellik Ekleme
1. Model sınıflarını `lib/models/` altında oluşturun
2. API servislerini `lib/services/` altında ekleyin
3. Provider'ları `lib/providers/` altında yönetin
4. UI bileşenlerini `lib/widgets/` altında oluşturun

### Tema Özelleştirme
Ana tema `lib/main.dart` dosyasında tanımlanmıştır. Amber renk paleti kullanılmaktadır.

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## İletişim

Geliştirici: [Adınız]
Email: [email@example.com]
