import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'item.dart';
import 'item_view.dart';

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
  final String response = await rootBundle.loadString('assets/items/items.json');
  final List<dynamic> jsonData = json.decode(response);
  setState(() {
    _items = jsonData.map((item) => Item.fromJson(item as Map<String, dynamic>)).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⌐◨-◨'),
      ),
      body: ListView.builder(
        restorationId: 'sampleItemListView',
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];

          return ListTile(
            title: Text(item.name),
            leading: CircleAvatar(
              foregroundImage: AssetImage('assets/items/covers/${item.address}${item.abId}.webp'),
            ),
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                SampleItemDetailsView.routeName,
                arguments: item.toJson(),
              );
            }
          );
        },
      ),
    );
  }
}
