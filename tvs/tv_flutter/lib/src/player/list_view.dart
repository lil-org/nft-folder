import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'item_view.dart';

class Item {
  final String name;
  final String address;
  final String abId;

  Item({required this.name, required this.address, required this.abId});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      address: json['address'],
      abId: json['abId'],
    );
  }
}

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
      _items = jsonData.map((item) => Item.fromJson(item)).toList();
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
              );
            }
          );
        },
      ),
    );
  }
}
