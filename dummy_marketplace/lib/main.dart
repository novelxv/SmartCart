import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
      title: 'Marketplace App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MarketplaceApp(),
    );
  }
}

class MarketplaceApp extends StatefulWidget {
  const MarketplaceApp({super.key});

  @override
  _MarketplaceAppState createState() => _MarketplaceAppState();
}

class _MarketplaceAppState extends State<MarketplaceApp> {
  final List<Product> products = [
    Product(name: 'Product 1', price: 10.0),
    Product(name: 'Product 2', price: 20.0),
    Product(name: 'Product 3', price: 15.0),
  ];

  final Map<Product, int> cartItems = {};

  void addToCart(Product product) {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('cartItems');
    ref.child(product.name).set({
      'name': product.name,
      'price': product.price.toDouble(),
      'quantity': (cartItems[product] ?? 0) + 1
    });
  }

  @override
  void initState() {
    super.initState();
    // Menunda tampilan SnackBar hingga setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReminder(context));
  }

  void _showReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminder!'),
          content: const Text('Fill in your needs list in the SmartCart App before continuing shopping.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Marketplace App'),
        backgroundColor: Colors.blue[100],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShoppingHistoryPage()),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text('\$${products[index].price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                setState(() {
                  cartItems.update(
                    products[index],
                    (quantity) => quantity + 1,
                    ifAbsent: () => 1,
                  );
                });
                // addToCart(products[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cartItems),
            ),
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<Product, int> cartItems;

  const CartPage(this.cartItems, {super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(widget.cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          var product = widget.cartItems.keys.elementAt(index);
          return ListTile(
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (widget.cartItems[product]! > 1) {
                        widget.cartItems[product] =
                            widget.cartItems[product]! - 1;
                      } else {
                        widget.cartItems.remove(product);
                      }
                    });
                  },
                ),
                Text(widget.cartItems[product].toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.cartItems[product] =
                          widget.cartItems[product]! + 1;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cartItems;

  const CheckoutPage(this.cartItems, {super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var entry in widget.cartItems.entries) {
      totalPrice += entry.key.price * entry.value;
    }
    return totalPrice;
  }

  Future<List<String>> _fetchNeedsChecklist() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('needsChecklist');
    DatabaseEvent event = await ref.once();
    List<String> checklistItems = [];

    if (event.snapshot.exists && event.snapshot.value is Map) {
      Map data = Map.from(event.snapshot.value as Map);
      for (var entry in data.entries) {
        Map itemMap = Map.from(entry.value);
        if (itemMap.containsKey('item')) {
          checklistItems.add(itemMap['item']);
        }
      }
    }
    return checklistItems;
  }

  void _validateCartItems(List<String> needsChecklist) {
    final cartItemsNames = widget.cartItems.keys.map((product) => product.name).toList();

    bool isValid = true;
    for (var itemName in cartItemsNames) {
      if (!needsChecklist.contains(itemName)) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      // Tampilkan warning karena ada barang yang tidak dibutuhkan
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('There are items in your cart that are not in your needs checklist. Please review your cart before proceeding.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      // Lanjutkan ke konfirmasi order jika tidak ada masalah
      completeCheckout();
    }
  }

  void completeCheckout() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('completedOrders');
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    ref.child(orderId).set({
      'orderDetails': widget.cartItems.entries.map((entry) {
        return {
          'name': entry.key.name,
          'price': entry.key.price,
          'quantity': entry.value,
        };
      }).toList(),
      'totalPrice': calculateTotalPrice(),
      'orderTime': orderId,
    });

    // Navigate to confirmation page after checkout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderConfirmationPage(),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    setCheckoutStatus(true);
    saveCartItems();
  }

  @override
  void dispose() {
    setCheckoutStatus(false);
    super.dispose();
  }

  void setCheckoutStatus(bool isInCheckout) {
    final DatabaseReference statusRef = FirebaseDatabase.instance.ref('checkoutStatus');
    statusRef.set({'isCurrentlyInCheckout': isInCheckout});
  }

  void saveCartItems() {
    final DatabaseReference cartRef = FirebaseDatabase.instance.ref('checkoutCartItems');
    // Menghapus item sebelumnya
    cartRef.remove().then((_) {
      // Menambahkan item saat ini ke database
      for (var entry in widget.cartItems.entries) {
        cartRef.child(entry.key.name).set({
          'name': entry.key.name,
          'price': entry.key.price,
          'quantity': entry.value,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                var product = widget.cartItems.keys.elementAt(index);
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: Text('Qty: ${widget.cartItems[product]}'),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate items before checkout
                List<String> needsChecklist = await _fetchNeedsChecklist();
                _validateCartItems(needsChecklist);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Complete Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.blue[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Thank you for your order!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi kembali ke halaman utama
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MarketplaceApp()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

class ShoppingHistoryPage extends StatefulWidget {
  const ShoppingHistoryPage({super.key});

  @override
  _ShoppingHistoryPageState createState() => _ShoppingHistoryPageState();
}

class _ShoppingHistoryPageState extends State<ShoppingHistoryPage> {
  late Future<List<Order>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('completedOrders');
    DatabaseEvent event = await ref.once();
    List<Order> orders = [];
    if (event.snapshot.exists) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      orders = data.entries.map((entry) {
        // Melakukan konversi eksplisit
        return Order.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Shopping History'),
        backgroundColor: Colors.blue[100],
      ),
      body: FutureBuilder<List<Order>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Order> orders = snapshot.data ?? [];
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Order ${orders[index].orderId}'),
                  subtitle: Text('Total: \$${orders[index].totalPrice}'),
                  onTap: () {},
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Order {
  final String orderId;
  final double totalPrice;
  final List<Map<String, dynamic>> orderDetails;

  Order(
      {required this.orderId,
      required this.totalPrice,
      required this.orderDetails});

  factory Order.fromMap(String id, Map<dynamic, dynamic> data) {
    double totalPrice = 0.0;
    if (data['totalPrice'] != null) {
      totalPrice = (data['totalPrice'] is int)
          ? (data['totalPrice'] as int).toDouble()
          : data['totalPrice'];
    }

    // Menggunakan `Map<String, dynamic>.from` untuk konversi eksplisit
    var orderDetails = List<Map<String, dynamic>>.from(
        data['orderDetails']?.map((item) => Map<String, dynamic>.from(item)) ??
            []);

    return Order(
      orderId: id,
      totalPrice: totalPrice,
      orderDetails: orderDetails,
    );
  }
}
