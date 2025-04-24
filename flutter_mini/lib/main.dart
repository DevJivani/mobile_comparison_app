import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechCompare Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6BFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(8),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
        ),
      ),
      home: const MobileListScreen(),
    );
  }
}

class Mobile {
  final String id;
  final String name;
  final String modelNumber;
  final String ram;
  final String rom;
  final String frontCamera;
  final String backCamera;
  final String display;
  final String height;
  final String width;
  final String weight;
  final String chargingPortType;
  final String description;
  final String imageUrl;
  final String releaseDate;
  final String processor;
  final String color;
  final String connectivity;
  final String features;
  final String simType;
  final String gpu;
  final String os;
  final int price;
  final bool availability;

  Mobile({
    required this.id,
    required this.name,
    required this.modelNumber,
    required this.ram,
    required this.rom,
    required this.frontCamera,
    required this.backCamera,
    required this.display,
    required this.height,
    required this.width,
    required this.weight,
    required this.chargingPortType,
    required this.description,
    required this.imageUrl,
    required this.releaseDate,
    required this.processor,
    required this.color,
    required this.connectivity,
    required this.features,
    required this.simType,
    required this.gpu,
    required this.os,
    required this.price,
    required this.availability,
  });

  factory Mobile.fromJson(Map<String, dynamic> json) {
    return Mobile(
      id: json['_id'] ?? 'unknown_id',
      name: json['name'] ?? 'Unknown',
      modelNumber: json['model_number'] ?? 'Unknown',
      ram: json['ram'] ?? 'N/A',
      rom: json['rom'] ?? 'N/A',
      frontCamera: json['front_camera'] ?? 'N/A',
      backCamera: json['back_camera'] ?? 'N/A',
      display: json['display'] ?? 'N/A',
      height: json['height'] ?? 'N/A',
      width: json['width'] ?? 'N/A',
      weight: json['weight'] ?? 'N/A',
      chargingPortType: json['charging_port_type'] ?? 'N/A',
      description: json['description'] ?? 'No description available',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/300',
      releaseDate: json['releaseDate'] ?? '1970-01-01T00:00:00.000Z',
      processor: json['processor'] ?? 'N/A',
      color: json['color'] ?? 'N/A',
      connectivity: json['connectivity'] ?? 'N/A',
      features: json['features'] ?? 'N/A',
      simType: json['sim_type'] ?? 'N/A',
      gpu: json['gpu'] ?? 'N/A',
      os: json['os'] ?? 'N/A',
      price: (json['price'] is int ? json['price'] : int.tryParse(json['price'].toString())) ?? 0,
      availability: json['availability'] ?? false,
    );
  }
}

class MobileListScreen extends StatefulWidget {
  const MobileListScreen({super.key});

  @override
  State<MobileListScreen> createState() => _MobileListScreenState();
}

class _MobileListScreenState extends State<MobileListScreen> {
  late Future<List<Mobile>> futureMobiles;
  List<Mobile> selectedMobiles = [];
  String? geminiSuggestion;
  bool isLoadingSuggestion = false;
  bool showComparison = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureMobiles = fetchMobiles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Mobile>> fetchMobiles() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/get_mobiles'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((mobile) => Mobile.fromJson(mobile)).toList();
      } else {
        throw Exception('Failed to load mobiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching mobiles: $e');
    }
  }

  Future<String> getGeminiSuggestion(List<Mobile> mobiles) async {
    const apiKey = 'AIzaSyCkU3Q60l-DSEyGwlgaOT7yf6nItmXVFng'; // Replace with your actual Gemini API key
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

    final prompt = '''
Compare the following two mobile phones and suggest which one is the best for purchase based on the provided specifications:

Mobile 1: ${mobiles[0].name} (${mobiles[0].modelNumber})
- Price: \$${mobiles[0].price}
- RAM: ${mobiles[0].ram}
- ROM: ${mobiles[0].rom}
- Front Camera: ${mobiles[0].frontCamera}
- Back Camera: ${mobiles[0].backCamera}
- Display: ${mobiles[0].display}
- Processor: ${mobiles[0].processor}
- OS: ${mobiles[0].os}
- Release Date: ${mobiles[0].releaseDate.split('T')[0]}
- Availability: ${mobiles[0].availability ? 'In Stock' : 'Out of Stock'}

Mobile 2: ${mobiles[1].name} (${mobiles[1].modelNumber})
- Price: \$${mobiles[1].price}
- RAM: ${mobiles[1].ram}
- ROM: ${mobiles[1].rom}
- Front Camera: ${mobiles[1].frontCamera}
- Back Camera: ${mobiles[1].backCamera}
- Display: ${mobiles[1].display}
- Processor: ${mobiles[1].processor}
- OS: ${mobiles[1].os}
- Release Date: ${mobiles[1].releaseDate.split('T')[0]}
- Availability: ${mobiles[1].availability ? 'In Stock' : 'Out of Stock'}

Provide a detailed comparison and suggestion on which one is better to buy considering:
1. Value for money (price vs. specs)
2. Performance (RAM, ROM, Processor)
3. Camera quality
4. Display quality
5. Software (OS)
6. How recent the model is
7. Availability
8. Any other factors you think are important

Format your response with:
- A brief introduction
- Comparison points in bullet points (use - for bullets)
- Clear recommendation at the end
''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get suggestion: ${response.body}');
    }
  }

  void compareMobiles() async {
    if (selectedMobiles.length == 2) {
      setState(() {
        isLoadingSuggestion = true;
        geminiSuggestion = null;
        showComparison = true;
      });
      try {
        final suggestion = await getGeminiSuggestion(selectedMobiles);
        setState(() {
          geminiSuggestion = suggestion;
          isLoadingSuggestion = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        setState(() {
          geminiSuggestion = 'Error fetching suggestion: $e';
          isLoadingSuggestion = false;
        });
      }
    }
  }

  void closeComparison() {
    setState(() {
      showComparison = false;
      selectedMobiles.clear();
      geminiSuggestion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechCompare Pro'),
        actions: [
          if (selectedMobiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${selectedMobiles.length}/2'),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                side: BorderSide.none,
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                avatar: Icon(Icons.compare_arrows, size: 18, color: Theme.of(context).colorScheme.primary),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<Mobile>>(
        future: futureMobiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                if (selectedMobiles.isNotEmpty && !showComparison)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Selected for Comparison',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (selectedMobiles.length == 2)
                          FilledButton.icon(
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Get AI Comparison'),
                            onPressed: compareMobiles,
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          )
                        else
                          Text(
                            'Select 1 more',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                      ],
                    ),
                  ),
                if (showComparison)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insights, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AI-Powered Comparison',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          onPressed: closeComparison,
                          tooltip: 'Close comparison',
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: showComparison
                      ? _buildComparisonView(context)
                      : _buildMobileListView(context, snapshot.data!),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return _buildErrorView(context, snapshot.error.toString());
          }
          return _buildLoadingView();
        },
      ),
    );
  }

  Widget _buildMobileListView(BuildContext context, List<Mobile> mobiles) {
    return ListView.builder(
      itemCount: mobiles.length,
      itemBuilder: (context, index) {
        final mobile = mobiles[index];
        final isSelected = selectedMobiles.contains(mobile);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isSelected
                  ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedMobiles.remove(mobile);
                  } else if (selectedMobiles.length < 2) {
                    selectedMobiles.add(mobile);
                  }
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: Image.network(
                          mobile.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                        ),
                        child: Text(
                          '\$${mobile.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mobile.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: mobile.availability
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: mobile.availability ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                mobile.availability ? 'In Stock' : 'Out of Stock',
                                style: TextStyle(
                                  color: mobile.availability ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mobile.modelNumber,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSpecChip(context, Icons.memory, mobile.ram),
                            _buildSpecChip(context, Icons.sd_storage, mobile.rom),
                            _buildSpecChip(context, Icons.camera_alt, '${mobile.backCamera.split('+')[0]} Cam'),
                            _buildSpecChip(context, Icons.smartphone, mobile.display.split(' ')[0]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mobile.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Released: ${mobile.releaseDate.split('T')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Icon(Icons.color_lens,
                                size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              mobile.color,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecChip(BuildContext context, IconData icon, String text) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      side: BorderSide.none,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildComparisonView(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildComparisonCard(context, selectedMobiles[0])),
              const SizedBox(width: 16),
              Expanded(child: _buildComparisonCard(context, selectedMobiles[1])),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Specifications Comparison',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                children: [
                  _buildTableRow(context, 'Feature', selectedMobiles[0].name, selectedMobiles[1].name,
                      isHeader: true),
                  _buildTableRow(context, 'Model', selectedMobiles[0].modelNumber, selectedMobiles[1].modelNumber),
                  _buildTableRow(context, 'Price', '\$${selectedMobiles[0].price}', '\$${selectedMobiles[1].price}'),
                  _buildTableRow(context, 'RAM', selectedMobiles[0].ram, selectedMobiles[1].ram),
                  _buildTableRow(context, 'Storage', selectedMobiles[0].rom, selectedMobiles[1].rom),
                  _buildTableRow(context, 'Front Camera', selectedMobiles[0].frontCamera,
                      selectedMobiles[1].frontCamera),
                  _buildTableRow(context, 'Rear Camera', selectedMobiles[0].backCamera,
                      selectedMobiles[1].backCamera),
                  _buildTableRow(context, 'Display', selectedMobiles[0].display, selectedMobiles[1].display),
                  _buildTableRow(context, 'Processor', selectedMobiles[0].processor, selectedMobiles[1].processor),
                  _buildTableRow(context, 'OS', selectedMobiles[0].os, selectedMobiles[1].os),
                  _buildTableRow(context, 'Release Date', selectedMobiles[0].releaseDate.split('T')[0],
                      selectedMobiles[1].releaseDate.split('T')[0]),
                  _buildTableRow(context, 'Status',
                      selectedMobiles[0].availability ? 'In Stock' : 'Out of Stock',
                      selectedMobiles[1].availability ? 'In Stock' : 'Out of Stock'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isLoadingSuggestion)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating AI Comparison...'),
                ],
              ),
            ),
          if (geminiSuggestion != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AI Recommendation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...geminiSuggestion!.split('\n').map((line) {
                      if (line.trim().isEmpty) return const SizedBox(height: 8);
                      if (line.startsWith('Comparison') || line.startsWith('Final Recommendation')) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            line,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        );
                      } else if (line.startsWith('-')) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  line.substring(1).trim(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            line,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, Mobile mobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                mobile.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.phone_android, size: 40, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mobile.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              mobile.modelNumber,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${mobile.price}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String feature, String value1, String value2,
      {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            feature,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value1,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value2,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'We couldn\'t load the mobile list',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  futureMobiles = fetchMobiles();
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Mobile Collection',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by AI Comparison',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}