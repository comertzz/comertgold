import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gold_model.dart';
import '../services/gold_api_service.dart';

class GoldDetailScreen extends StatefulWidget {
  final GoldModel gold;

  const GoldDetailScreen({
    super.key,
    required this.gold,
  });

  @override
  State<GoldDetailScreen> createState() => _GoldDetailScreenState();
}

class _GoldDetailScreenState extends State<GoldDetailScreen> {
  String selectedPeriod = '1G'; // 1G, 1H, 1A, 1Y
  List<GoldModel> historicalData = [];
  bool isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ilk veriyi yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistoricalData(selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.gold.name ?? 'Altın Detayı',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Paylaşım fonksiyonu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPriceCard(),
            _buildPeriodSelector(),
            _buildChart(),
            _buildDetailsCard(),
            _buildHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    final isPositive = widget.gold.change?.startsWith('+') ?? false;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade100,
            Colors.amber.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade200.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.gold.name ?? 'Bilinmeyen',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPriceColumn('Alış', widget.gold.buying, Colors.green),
              Container(
                width: 1,
                height: 60,
                color: Colors.amber.shade400,
              ),
              _buildPriceColumn('Satış', widget.gold.selling, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: changeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.gold.change ?? '0.00'} (${widget.gold.changePercent ?? '0.00%'})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: changeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Son güncelleme: ${widget.gold.time ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, double? price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₺${price?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('1G', '1 Gün'),
          _buildPeriodButton('1H', '1 Hafta'),
          _buildPeriodButton('1A', '1 Ay'),
          _buildPeriodButton('1Y', '1 Yıl'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
        _loadHistoricalData(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Grafik verilerini hazırla
    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    if (historicalData.isNotEmpty) {
      for (int i = 0; i < historicalData.length; i++) {
        double price = historicalData[i].buying ?? 0;
        spots.add(FlSpot(i.toDouble(), price));
        if (price < minY) minY = price;
        if (price > maxY) maxY = price;
      }
    } else {
      // Varsayılan veriler
      spots = [
        FlSpot(0, widget.gold.buying ?? 100),
        FlSpot(1, (widget.gold.buying ?? 100) + 2),
        FlSpot(2, (widget.gold.buying ?? 100) - 1),
        FlSpot(3, (widget.gold.buying ?? 100) + 3),
        FlSpot(4, (widget.gold.buying ?? 100) + 1),
      ];
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    
    // Y ekseni için padding ekle
    double yPadding = (maxY - minY) * 0.1;
    minY = minY - yPadding;
    maxY = maxY + yPadding;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fiyat Grafiği',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLoadingHistory)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: spots.length > 10 ? 2 : 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= spots.length) return const Text('');
                        
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        
                        String label = '';
                        switch (selectedPeriod) {
                          case '1G':
                            label = '${value.toInt()}:00';
                            break;
                          case '1H':
                            final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                            label = days[value.toInt() % 7];
                            break;
                          case '1A':
                            label = '${value.toInt() + 1}';
                            break;
                          case '1Y':
                            final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
                            label = months[value.toInt() % 12];
                            break;
                        }
                        
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(label, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY - minY) / 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '₺${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.amber.shade600,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 20, // Çok fazla nokta varsa gösterme
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.amber.shade700,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade200.withOpacity(0.3),
                          Colors.amber.shade100.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.amber.shade700,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        String timeLabel = '';
                        switch (selectedPeriod) {
                          case '1G':
                            timeLabel = '${barSpot.x.toInt()}:00';
                            break;
                          case '1H':
                            final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
                            timeLabel = days[barSpot.x.toInt() % 7];
                            break;
                          case '1A':
                            timeLabel = '${barSpot.x.toInt() + 1}. Gün';
                            break;
                          case '1Y':
                            final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
                            timeLabel = months[barSpot.x.toInt() % 12];
                            break;
                        }
                        
                        return LineTooltipItem(
                          '₺${barSpot.y.toStringAsFixed(2)}\n$timeLabel',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detaylı Bilgiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Kod', widget.gold.code ?? 'N/A'),
          _buildDetailRow('Alış Fiyatı', '₺${widget.gold.buying?.toStringAsFixed(2) ?? '0.00'}'),
          _buildDetailRow('Satış Fiyatı', '₺${widget.gold.selling?.toStringAsFixed(2) ?? '0.00'}'),
          _buildDetailRow('Değişim', '${widget.gold.change ?? '0.00'} (${widget.gold.changePercent ?? '0.00%'})'),
          _buildDetailRow('Son Güncelleme', widget.gold.time ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Geçmiş Veriler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (historicalData.isNotEmpty) ...[
            _buildHistoryRow('En Düşük', '₺${historicalData.map((e) => e.buying ?? 0).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}'),
            _buildHistoryRow('En Yüksek', '₺${historicalData.map((e) => e.buying ?? 0).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}'),
            _buildHistoryRow('Ortalama', '₺${(historicalData.map((e) => e.buying ?? 0).reduce((a, b) => a + b) / historicalData.length).toStringAsFixed(2)}'),
          ] else ...[
            _buildHistoryRow('1 Gün Önce', '₺${((widget.gold.buying ?? 0) * 0.98).toStringAsFixed(2)}'),
            _buildHistoryRow('1 Hafta Önce', '₺${((widget.gold.buying ?? 0) * 0.95).toStringAsFixed(2)}'),
            _buildHistoryRow('1 Ay Önce', '₺${((widget.gold.buying ?? 0) * 0.90).toStringAsFixed(2)}'),
            _buildHistoryRow('1 Yıl Önce', '₺${((widget.gold.buying ?? 0) * 0.80).toStringAsFixed(2)}'),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String period, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHistoricalData(String period) async {
    setState(() {
      isLoadingHistory = true;
    });

    try {
      // API'den geçmiş verileri çek
      print('Geçmiş veriler yükleniyor: $period');
      
      // API servisinden geçmiş verileri al
      final apiService = GoldApiService();
      final historicalDataList = await apiService.getHistoricalPrices(period);
      
      setState(() {
        historicalData = historicalDataList;
        isLoadingHistory = false;
      });
    } catch (e) {
      print('Geçmiş veri yükleme hatası: $e');
      setState(() {
        isLoadingHistory = false;
      });
    }
  }
} 