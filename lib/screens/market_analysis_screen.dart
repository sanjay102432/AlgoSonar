import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';

class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> {
  List<Map<String, dynamic>> marketData = [];
  bool isLoading = true;

  final List<String> symbols = [
    'BTCUSDT',
    'ETHUSDT',
    'PAXGUSDT',
    'XAGUSDT',
    'BNBUSDT',
    'SOLUSDT',
    'DOGEUSDT',
    'MATICUSDT',
    'AVAXUSDT',
    'LTCUSDT',
  ];

  final Map<String, String> displayNames = {
    'BTCUSDT': 'Bitcoin',
    'ETHUSDT': 'Ethereum',
    'PAXGUSDT': 'Gold',
    'XAGUSDT': 'Silver',
    'BNBUSDT': 'BNB',
    'SOLUSDT': 'Solana',
    'DOGEUSDT': 'Dogecoin',
    'MATICUSDT': 'Polygon',
    'AVAXUSDT': 'Avalanche',
    'LTCUSDT': 'Litecoin',
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
    // Auto-update prices every 15 seconds to avoid constant animations
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchMarketData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final parsedData = <Map<String, dynamic>>[];
        for (var symbol in symbols) {
          try {
            final item = data.firstWhere(
              (element) => element['symbol'] == symbol,
              orElse: () => <String, dynamic>{},
            );
            if (item.isNotEmpty && item['price'] != null) {
              final price = double.parse(item['price'].toString());
              parsedData.add({
                'name': displayNames[symbol],
                'symbol': symbol,
                'price': '\$${price.toStringAsFixed(2)}',
                'rawPrice': price,
              });
            }
          } catch (e) {
            continue;
          }
        }

        if (mounted) {
          setState(() {
            marketData = parsedData;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Market analysis'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: marketData.length,
              itemBuilder: (context, index) {
                final item = marketData[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      _showCoinPairs(context, item['name'], item['symbol']);
                    },
                    child: PriceChartCard(
                      name: item['name'],
                      symbol: item['symbol'],
                      price: item['price'],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCoinPairs(String symbol) async {
    try {
      final baseAsset = symbol.replaceAll('USDT', '');
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> pairs = [];

        for (var item in data) {
          final pair = item['symbol'] as String?;
          if (pair != null && pair.startsWith(baseAsset)) {
            try {
              final price = double.parse(item['price'].toString());
              pairs.add({'pair': pair, 'price': price});
            } catch (e) {
              continue;
            }
          }
        }

        // Sort by quote asset (most common: USDT, BUSD, USDC, BUSL, etc.)
        pairs.sort((a, b) {
          final aQuote = a['pair'].toString().replaceAll(baseAsset, '');
          final bQuote = b['pair'].toString().replaceAll(baseAsset, '');

          const priority = [
            'USDT',
            'BUSD',
            'USDC',
            'BUSL',
            'ETH',
            'BNB',
            'BTC',
          ];
          final aPriority = priority.indexOf(aQuote);
          final bPriority = priority.indexOf(bQuote);

          if (aPriority != -1 && bPriority != -1) {
            return aPriority.compareTo(bPriority);
          }
          return aPriority != -1 ? -1 : 1;
        });

        return pairs.take(20).toList(); // Limit to 20 top pairs
      }
    } catch (e) {
      //
    }
    return [];
  }

  void _showCoinPairs(BuildContext context, String name, String symbol) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CoinPairsBottomSheet(
        coinName: name,
        baseSymbol: symbol.replaceAll('USDT', ''),
        fetchPairs: _fetchCoinPairs,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}

class PriceChartCard extends StatefulWidget {
  final String name;
  final String symbol;
  final String price;

  const PriceChartCard({
    required this.name,
    required this.symbol,
    required this.price,
    super.key,
  });

  @override
  State<PriceChartCard> createState() => _PriceChartCardState();
}

class _PriceChartCardState extends State<PriceChartCard> {
  late Future<List<FlSpot>> _priceHistory;
  String _selectedTimeframe = '1h';

  final List<String> timeframes = ['1h', '4h', '12h', '1d'];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() {
    _priceHistory = _fetchHistoryWithTimeframe(
      widget.symbol,
      _selectedTimeframe,
    );
  }

  Future<List<FlSpot>> _fetchHistoryWithTimeframe(
    String symbol,
    String timeframe,
  ) async {
    const Map<String, String> intervalMap = {
      '1h': '5m',
      '4h': '15m',
      '12h': '1h',
      '1d': '4h',
    };

    const Map<String, int> limitMap = {'1h': 12, '4h': 16, '12h': 12, '1d': 6};

    try {
      final interval = intervalMap[timeframe] ?? '1h';
      final limit = limitMap[timeframe] ?? 12;

      final response = await http.get(
        Uri.parse(
          'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<FlSpot> spots = [];
        for (int i = 0; i < data.length; i++) {
          try {
            if (data[i] is List && data[i].length > 4) {
              final closePrice = double.parse(data[i][4].toString());
              spots.add(FlSpot(i.toDouble(), closePrice));
            }
          } catch (e) {
            continue;
          }
        }
        return spots;
      }
    } catch (e) {
      //
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with name and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Timeframe buttons - non-scrollable for better control
            Wrap(
              spacing: 8,
              children: timeframes.map((timeframe) {
                final isSelected = _selectedTimeframe == timeframe;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeframe = timeframe;
                      _loadChartData();
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      timeframe,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Chart
            FutureBuilder<List<FlSpot>>(
              future: _priceHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SizedBox(
                      height: 280,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 280,
                    child: const Center(child: Text('No chart data available')),
                  );
                }

                final spots = snapshot.data!;
                return SizedBox(
                  height: 280,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      right: 8,
                      bottom: 12,
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _calculateInterval(spots),
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withValues(alpha: 0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                int interval = 3;
                                if (_selectedTimeframe == '1d') {
                                  interval = 1;
                                } else if (_selectedTimeframe == '12h') {
                                  interval = 2;
                                } else if (_selectedTimeframe == '4h') {
                                  interval = 4;
                                }

                                if (index % interval == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${index * _getHourMultiplier()}h',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 55,
                              interval: _calculateInterval(spots),
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    _formatPrice(value),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            left: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: const Color.fromARGB(255, 181, 13, 211),
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(
                                    255,
                                    13,
                                    211,
                                    165,
                                  ).withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: (spots.length - 1).toDouble(),
                        minY: _getMinPrice(spots),
                        maxY: _getMaxPrice(spots),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _getHourMultiplier() {
    switch (_selectedTimeframe) {
      case '1h':
        return 1;
      case '4h':
        return 1;
      case '12h':
        return 1;
      case '1d':
        return 4;
      default:
        return 1;
    }
  }

  double _getMinPrice(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxPrice(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  }

  double _calculateInterval(List<FlSpot> spots) {
    final minY = _getMinPrice(spots);
    final maxY = _getMaxPrice(spots);
    final range = maxY - minY;

    // Prevent division by zero or very small ranges
    if (range == 0 || range < 0.01) {
      return (maxY * 0.1).abs() > 0 ? (maxY * 0.1).abs() : 1;
    }

    double interval = range / 5;

    // Round interval to clean number
    if (interval > 1000) {
      interval = (interval / 1000).round() * 1000;
    } else if (interval > 100) {
      interval = (interval / 100).round() * 100;
    } else if (interval > 10) {
      interval = (interval / 10).round() * 10;
    } else if (interval > 0.01) {
      interval = (interval * 100).round() / 100;
    } else {
      interval = 0.01;
    }

    return interval;
  }

  String _formatPrice(double price) {
    if (price > 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}k';
    }
    return '\$${price.toStringAsFixed(0)}';
  }
}

class CoinPairsBottomSheet extends StatefulWidget {
  final String coinName;
  final String baseSymbol;
  final Future<List<Map<String, dynamic>>> Function(String) fetchPairs;

  const CoinPairsBottomSheet({
    required this.coinName,
    required this.baseSymbol,
    required this.fetchPairs,
    super.key,
  });

  @override
  State<CoinPairsBottomSheet> createState() => _CoinPairsBottomSheetState();
}

class _CoinPairsBottomSheetState extends State<CoinPairsBottomSheet> {
  late Future<List<Map<String, dynamic>>> _pairsFuture;

  @override
  void initState() {
    super.initState();
    _pairsFuture = widget.fetchPairs(widget.baseSymbol);
  }

  String _formatPrice(double price) {
    if (price > 100) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price > 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsExponential(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.coinName} Trading Pairs',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All available trading pairs for ${widget.baseSymbol}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Pairs list
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _pairsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No trading pairs found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    final pairs = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pairs.length,
                      itemBuilder: (context, index) {
                        final pair = pairs[index];
                        final pairSymbol = pair['pair'] as String;
                        final price = pair['price'] as double;
                        final quote = pairSymbol.replaceAll(
                          widget.baseSymbol,
                          '',
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pairSymbol,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Quote: $quote',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatPrice(price),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
