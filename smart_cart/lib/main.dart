import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Checklist App',
      home: ChecklistScreen(),
    );
  }
}

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              onSubmitted: _addItem,
              decoration: InputDecoration(
                labelText: 'Enter an item',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
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
                    icon: Icon(Icons.delete),
                    onPressed: () => _toggleItem(index),
                  ),
                  onTap: () => _toggleItem(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
