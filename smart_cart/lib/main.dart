import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

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
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Atau splash screen
        } else if (snapshot.hasData) {
          return const MainScreen(); // Pengguna sudah login
        } else {
          return const LoginPage(); // Pengguna belum login
        }
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Sign in with Google'),
              onPressed: () async {
                User? user = await signInWithGoogle();
                if (user != null) {
                  // Navigasi ke layar utama
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('Continue without signing in'),
              onPressed: () {
                // Navigasi ke layar utama tanpa login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    return null; // Pengguna membatalkan proses login
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  return userCredential.user;
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
    const ShoppingHistory(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
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
  final TextEditingController _textController = TextEditingController();

  void _addItem(String item) {
    if (item.isNotEmpty) {
      database.ref('needsChecklist').push().set({'item': item});
      _textController.clear();
    }
  }

  void _removeItem(String key) {
    database.ref('needsChecklist/$key').remove();
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
          child: StreamBuilder(
            stream: database.ref('needsChecklist').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: Text('No items added yet'));
              }

              Map<dynamic, dynamic> items =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              return ListView(
                children: items.entries.map((e) {
                  return ListTile(
                    title: Text(e.value['item']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.green),
                      onPressed: () => _removeItem(e.key),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShoppingHistory extends StatefulWidget {
  const ShoppingHistory({super.key});

  @override
  _ShoppingHistoryState createState() => _ShoppingHistoryState();
}

class _ShoppingHistoryState extends State<ShoppingHistory> {
  int selectedMarketplace = 1; // Default to Marketplace 1

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Tombol untuk memilih marketplace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _marketplaceButton("MP 1", 1)),
              Expanded(child: _marketplaceButton("MP 2", 2)),
              Expanded(child: _marketplaceButton("MP 3", 3)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            child: selectedMarketplace == 1
                ? _buildOrderHistory()
                : const Placeholder(fallbackHeight: 100),
          ),
        ],
      ),
    );
  }

  Widget _marketplaceButton(String title, int marketplaceNumber) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedMarketplace = marketplaceNumber;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: marketplaceNumber == selectedMarketplace
              ? Colors.green
              : Colors.grey,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildOrderHistory() {
    return StreamBuilder(
      stream: database.ref('completedOrders').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text('No orders found'));
        }

        Map<dynamic, dynamic> orders =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var orderKey = orders.keys.elementAt(index);
            var order = orders[orderKey];
            return ListTile(
              title: Text('Order ID: $orderKey'),
              subtitle: Text('Total Price: \$${order['totalPrice']}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(orderKey: orderKey),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final String orderKey;

  OrderDetailsPage({required this.orderKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details - $orderKey'),
      ),
      body: StreamBuilder(
        stream: database.ref('completedOrders/$orderKey/orderDetails').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('No details found for this order'));
          }

          var data = snapshot.data!.snapshot.value;
          List<dynamic> orderDetails;

          if (data is List<dynamic>) {
            orderDetails = data;
          } else if (data is Map<dynamic, dynamic>) {
            orderDetails = data.values.toList();
          } else {
            return const Center(child: Text('Unexpected data format'));
          }

          return ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
              var detail = orderDetails[index] as Map<dynamic, dynamic>;
              return ListTile(
                title: Text(detail['name'] ?? 'Unknown'),
                subtitle: Text('Quantity: ${detail['quantity'] ?? 'N/A'}'),
                trailing: Text('\$${detail['price'] ?? '0'}'),
              );
            },
          );
        },
      )
    );
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
