import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        appBarTheme: AppBarTheme(
          color: Colors.green,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.green.shade600,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.white),
          fillColor: MaterialStateProperty.all(Colors.green),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    NeedsChecklist(),
    ShoppingHistoryPlaceholder(),
    MarketplacePlaceholder(),
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
        title: Text('SmartCart App'),
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
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: _textController,
            onSubmitted: _addItem,
            decoration: InputDecoration(
              labelText: 'Enter an item',
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: Colors.green),
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
                  icon: Icon(Icons.delete, color: Colors.green),
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
  // Placeholder untuk Shopping History
  @override
  Widget build(BuildContext context) {
    return Placeholder(fallbackHeight: 100);
  }
}

class MarketplacePlaceholder extends StatelessWidget {
  // Placeholder untuk Marketplace
  @override
  Widget build(BuildContext context) {
    return Placeholder(fallbackHeight: 100);
  }
}
