import 'dart:convert';
import 'package:flutter/services.dart';
import 'item.dart';
import 'dart:math';

class ItemRepository {
  static final ItemRepository _instance = ItemRepository._internal();

  factory ItemRepository() {
    return _instance;
  }

  ItemRepository._internal();

  List<Item> _items = [];

  Future<void> loadItems() async {
    final String response = await rootBundle.loadString('assets/items/items.json');
    final List<dynamic> jsonData = json.decode(response);
    _items = jsonData.map((item) => Item.fromJson(item as Map<String, dynamic>)).toList();
  }

  List<Item> get items => _items;

  Item getRandomItem() {
    if (_items.isEmpty) {
      throw Exception('No items available');
    }
    final random = Random();
    return _items[random.nextInt(_items.length)];
  }
}