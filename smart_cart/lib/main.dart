import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCart App',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.greenAccent,
        ),
        scaffoldBackgroundColor: Colors.green.shade50,
        appBarTheme: const AppBarTheme(
          color: Colors.green,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.green.shade600,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.white),
          fillColor: MaterialStateProperty.all(Colors.green),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const NeedsChecklist(),
    const ShoppingHistoryPlaceholder(),
    const MarketplacePlaceholder(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCart App'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Needs Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Shopping History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Marketplace',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class NeedsChecklist extends StatefulWidget {
  const NeedsChecklist({super.key});

  @override
  _NeedsChecklistState createState() => _NeedsChecklistState();
}

class _NeedsChecklistState extends State<NeedsChecklist> {
  final List<String> _items = [];
  final TextEditingController _textController = TextEditingController();

  void _addItem(String item) {
    if (item.isNotEmpty) {
      setState(() {
        _items.add(item);
      });
      _textController.clear();
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _textController,
            onSubmitted: _addItem,
            decoration: InputDecoration(
              labelText: 'Enter an item',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () => _addItem(_textController.text),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_items[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.green),
                  onPressed: () => _toggleItem(index),
                ),
                onTap: () => _toggleItem(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShoppingHistoryPlaceholder extends StatelessWidget {
  const ShoppingHistoryPlaceholder({super.key});

  // Placeholder untuk Shopping History
  @override
  Widget build(BuildContext context) {
    return const Placeholder(fallbackHeight: 100);
  }
}

class MarketplacePlaceholder extends StatelessWidget {
  const MarketplacePlaceholder({super.key});

  // Placeholder untuk Marketplace
  @override
  Widget build(BuildContext context) {
    return const Placeholder(fallbackHeight: 100);
  }
}
