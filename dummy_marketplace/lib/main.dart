import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MarketplaceApp(),
    );
  }
}

class MarketplaceApp extends StatefulWidget {
  @override
  _MarketplaceAppState createState() => _MarketplaceAppState();
}

class _MarketplaceAppState extends State<MarketplaceApp> {
  List<Product> products = [
    Product('Product 1', 10.0),
    Product('Product 2', 20.0),
    Product('Product 3', 15.0),
  ];

  Map<Product, int> cartItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Marketplace App'),
        backgroundColor: Colors.blue[100],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text('\$${products[index].price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                setState(() {
                  cartItems.update(
                    products[index],
                    (quantity) => quantity + 1,
                    ifAbsent: () => 1,
                  );
                });
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
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<Product, int> cartItems;

  CartPage(this.cartItems);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutPage(Map.from(widget.cartItems)),
                ),
              );
            },
          )
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
                  icon: Icon(Icons.remove),
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
                  icon: Icon(Icons.add),
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

  CheckoutPage(this.cartItems);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;
    widget.cartItems.forEach((product, quantity) {
      totalPrice += product.price * quantity;
    });

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Checkout'),
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
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final double price;

  Product(this.name, this.price);

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