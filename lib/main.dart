import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chroma Store',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const AppStartPage(),
    );
  }
}

class AppStartPage extends StatelessWidget {
  const AppStartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.blue],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50), // Adjust the height as needed
            Text(
              'Welcome to',
              style: TextStyle(
                fontFamily: 'Poppins', // Specify the font family
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Chroma Store',
              style: TextStyle(
                fontFamily: 'Poppins', // Specify the font family
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StoreSidePage()),
                        );
                      },
                      child: const Text('Store Side'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomerSidePage()),
                        );
                      },
                      child: const Text('Customer Side'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50), // Adjust the height as needed
          ],
        ),
      ),
    );
  }
}

class StoreSidePage extends StatefulWidget {
  const StoreSidePage({Key? key}) : super(key: key);

  @override
  _StoreSidePageState createState() => _StoreSidePageState();
}

class _StoreSidePageState extends State<StoreSidePage> {
  String? selectedStore;
  final List<String> stores = [
    'Store 1 - Mumbai',
    'Store 2 - Delhi',
    'Store 3 - Bangalore',
    'Store 4 - Chennai'
  ];

  void _navigateToDataAnalysis() {
    if (selectedStore != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DataAnalysisPage()),
      );
    } else {
      _showErrorSnackBar('Please select a store');
    }
  }

  void _navigateToCustomerAnalysis() {
    if (selectedStore != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CustomerAnalysisPage()),
      );
    } else {
      _showErrorSnackBar('Please select a store');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Side'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: Text('Select a store'),
              value: selectedStore,
              onChanged: (newValue) {
                setState(() {
                  selectedStore = newValue;
                });
              },
              items: stores.map<DropdownMenuItem<String>>((String store) {
                return DropdownMenuItem<String>(
                  value: store,
                  child: Text(store),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToDataAnalysis,
              child: Text('Data Analysis'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToCustomerAnalysis,
              child: Text('Customer Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerSidePage extends StatefulWidget {
  const CustomerSidePage({Key? key}) : super(key: key);

  @override
  _CustomerSidePageState createState() => _CustomerSidePageState();
}

class _CustomerSidePageState extends State<CustomerSidePage> {
  User? user;
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Recommendation> recommendations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProducts();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('https://rodincode.pythonanywhere.com/api/user/1'));
      if (response.statusCode == 200) {
        setState(() {
          user = User.fromJson(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load user data: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://rodincode.pythonanywhere.com/api/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = (json.decode(response.body) as List)
              .map((data) => Product.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load products: $e');
    }
  }

  Future<void> _getRecommendations() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': user?.id}),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = (jsonResponse as List)
              .map((data) => Recommendation.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get recommendations: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Side'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(onSearch: _filterProducts),
                  const SizedBox(height: 16),
                  if (user != null) UserInfoWidget(user: user!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _getRecommendations,
                    child:
                        Text(isLoading ? 'Loading...' : 'Get Recommendations'),
                  ),
                  const SizedBox(height: 16),
                  if (recommendations.isNotEmpty)
                    RecommendationsWidget(
                      recommendations: recommendations,
                      onPurchaseTimingPressed: (productId) {},
                      onJourneyPlanPressed: (productId, stage) {},
                      products: products,
                    ),
                  const SizedBox(height: 16),
                  Text('Available Products:',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.purple)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = (filteredProducts.isNotEmpty
                    ? filteredProducts
                    : products)[index];
                return ProductListItem(product: product);
              },
              childCount: filteredProducts.isNotEmpty
                  ? filteredProducts.length
                  : products.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product.category}'),
            Text('Compatibility: ${product.compatibility.join(", ")}'),
            Text('Features: ${product.features.join(", ")}'),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(product.name[0],
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearch,
        decoration: const InputDecoration(
          hintText: 'Search products...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Recommendation> recommendations = [];
  bool isLoading = false;
  String? selectedStore; // To store the selected store

  final List<String> stores = [
    'Store 1 - Mumbai',
    'Store 2 - Delhi',
    'Store 3 - Bangalore',
    'Store 4 - Chennai'
  ]; // List of stores in India

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProducts();
  }

  void _navigateToDataAnalysis() {
    if (selectedStore != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DataAnalysisPage()),
      );
    } else {
      _showErrorSnackBar('Please select a store');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('https://rodincode.pythonanywhere.com/api/user/1'));
      if (response.statusCode == 200) {
        setState(() {
          user = User.fromJson(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load user data: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://rodincode.pythonanywhere.com/api/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = (json.decode(response.body) as List)
              .map((data) => Product.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load products: $e');
    }
  }

  Future<void> _getRecommendations() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': user?.id}),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = (jsonResponse as List)
              .map((data) => Recommendation.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get recommendations: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getPurchaseTiming(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/purchase-timing'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'productId': productId}),
      );
      if (response.statusCode == 200) {
        final timingAdvice = json.decode(response.body);
        _showDialog('Purchase Timing Advice', timingAdvice);
      } else {
        throw Exception('Failed to get purchase timing advice');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get purchase timing advice: $e');
    }
  }

  Future<void> _getCustomerJourneyPlan(int productId, String stage) async {
    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/customer-journey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'userId': user?.id, 'productId': productId, 'stage': stage}),
      );
      if (response.statusCode == 200) {
        final journeyPlan = json.decode(response.body);
        _showDialog('Customer Journey Plan', journeyPlan);
      } else {
        throw Exception('Failed to get customer journey plan');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get customer journey plan: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showDialog(String title, Map<String, dynamic> content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: content.entries.map((entry) {
                if (entry.value is List) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key}:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...((entry.value as List).map((item) => Text('• $item'))),
                    ],
                  );
                } else {
                  return Text('${entry.key}: ${entry.value}');
                }
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToAnalysisPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataAnalysisPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Chroma Store',
                  style: TextStyle(color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple, Colors.blue],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(onSearch: _filterProducts),
                  const SizedBox(height: 16),
                  if (user != null) UserInfoWidget(user: user!),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Dropdown for Store Selection
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text('Select a store'),
                          value: selectedStore,
                          onChanged: (newValue) {
                            setState(() {
                              selectedStore = newValue;
                            });
                          },
                          items: <String>[
                            'Store 1 - Mumbai',
                            'Store 2 - Delhi',
                            'Store 3 - Bangalore',
                            'Store 4 - Chennai'
                          ].map<DropdownMenuItem<String>>((String store) {
                            return DropdownMenuItem<String>(
                              value: store,
                              child: Text(store),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                          width:
                              8), // Add some space between Dropdown and Button
                      // Data Analysis Button
                      ElevatedButton(
                        onPressed: _navigateToAnalysisPage,
                        child: Text('Data Analysis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _getRecommendations,
                    child:
                        Text(isLoading ? 'Loading...' : 'Get Recommendations'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recommendations.isNotEmpty)
                    RecommendationsWidget(
                      recommendations: recommendations,
                      onPurchaseTimingPressed: _getPurchaseTiming,
                      onJourneyPlanPressed: _getCustomerJourneyPlan,
                      products: products,
                    ),
                  const SizedBox(height: 16),
                  Text('Available Products:',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.purple)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = (filteredProducts.isNotEmpty
                    ? filteredProducts
                    : products)[index];
                return ProductListItem(product: product);
              },
              childCount: filteredProducts.isNotEmpty
                  ? filteredProducts.length
                  : products.length,
            ),
          ),
        ],
      ),
    );
  }
}

class DataAnalysisPage extends StatefulWidget {
  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  final TextEditingController _queryController = TextEditingController();
  String _analysisResult = '';
  String? _visualizationData;
  bool _isLoading = false;

  Future<void> _analyzeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/forward-analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': _queryController.text}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _analysisResult = result['analysis'];
          _visualizationData = result['visualization'];
        });
      } else {
        throw Exception('Failed to analyze data');
      }
    } catch (e) {
      print('Error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Enter your analysis query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeData,
              child: Text(_isLoading ? 'Analyzing...' : 'Analyze Data'),
            ),
            SizedBox(height: 16),
            Text(
              'Analysis Result:',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_analysisResult),
                    SizedBox(height: 16),
                    if (_visualizationData != null)
                      Image.memory(
                        base64Decode(_visualizationData!),
                        fit: BoxFit.contain,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  final User user;

  const UserInfoWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, ${user.name}',
            style: Theme.of(context).textTheme.headline5),
        const SizedBox(height: 8),
        Text('Your devices: ${user.devices.join(", ")}'),
        Text('Your preferences: ${user.preferences.join(", ")}'),
      ],
    );
  }
}

class RecommendationsWidget extends StatelessWidget {
  final List<Recommendation> recommendations;
  final Function(int) onPurchaseTimingPressed;
  final Function(int, String) onJourneyPlanPressed;
  final List<Product> products;

  const RecommendationsWidget({
    Key? key,
    required this.recommendations,
    required this.onPurchaseTimingPressed,
    required this.onJourneyPlanPressed,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommendations:', style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => RecommendationCard(
              recommendation: rec,
              onPurchaseTimingPressed: onPurchaseTimingPressed,
              onJourneyPlanPressed: onJourneyPlanPressed,
              products: products,
            )),
      ],
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final Function(int) onPurchaseTimingPressed;
  final Function(int, String) onJourneyPlanPressed;
  final List<Product> products;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    required this.onPurchaseTimingPressed,
    required this.onJourneyPlanPressed,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product =
        products.firstWhere((p) => p.name == recommendation.product);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.product,
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('Explanation: ${recommendation.explanation}'),
            Text('Compatibility: ${recommendation.compatibility}'),
            Text('Benefits: ${recommendation.benefits}'),
            const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () => onPurchaseTimingPressed(product.id),
            //       child: const Text('Purchase Timing'),
            //     ),
            //     ElevatedButton(
            //       onPressed: () =>
            //           onJourneyPlanPressed(product.id, 'marketing'),
            //       child: const Text('Journey Plan'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class ProductListWidget extends StatelessWidget {
  final List<Product> products;

  const ProductListWidget({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products
          .map((product) => ListTile(
                title: Text(product.name),
                subtitle: Text(
                    'Category: ${product.category}\nCompatibility: ${product.compatibility.join(", ")}\nFeatures: ${product.features.join(", ")}'),
              ))
          .toList(),
    );
  }
}

class User {
  final int id;
  final String name;
  final List<String> devices;
  final List<String> preferences;

  User(
      {required this.id,
      required this.name,
      required this.devices,
      required this.preferences});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      devices: List<String>.from(json['devices']),
      preferences: List<String>.from(json['preferences']),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String category;
  final List<String> compatibility;
  final List<String> features;

  Product(
      {required this.id,
      required this.name,
      required this.category,
      required this.compatibility,
      required this.features});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      compatibility: List<String>.from(json['compatibility']),
      features: List<String>.from(json['features']),
    );
  }
}

class Recommendation {
  final String product;
  final String explanation;
  final String compatibility;
  final String benefits;

  Recommendation({
    required this.product,
    required this.explanation,
    required this.compatibility,
    required this.benefits,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      product: json['product'] ?? '',
      explanation: json['explanation'] ?? '',
      compatibility: json['compatibility'] ?? '',
      benefits: json['benefits'] ?? '',
    );
  }
}

// Add a new CustomerAnalysisPage
class CustomerAnalysisPage extends StatefulWidget {
  @override
  _CustomerAnalysisPageState createState() => _CustomerAnalysisPageState();
}

class _CustomerAnalysisPageState extends State<CustomerAnalysisPage> {
  final TextEditingController _queryController = TextEditingController();
  String _analysisResult = '';
  String? _visualizationData;
  bool _isLoading = false;

  Future<void> _analyzeCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://rodincode.pythonanywhere.com/api/analyze-customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': _queryController.text}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _analysisResult = result['analysis'];
          _visualizationData = result['visualization'];
        });
      } else {
        throw Exception('Failed to analyze customer data');
      }
    } catch (e) {
      print('Error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Enter your customer analysis query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeCustomerData,
              child:
                  Text(_isLoading ? 'Analyzing...' : 'Analyze Customer Data'),
            ),
            SizedBox(height: 16),
            Text(
              'Analysis Result:',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_analysisResult),
                    SizedBox(height: 16),
                    if (_visualizationData != null)
                      Image.memory(
                        base64Decode(_visualizationData!),
                        fit: BoxFit.contain,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
