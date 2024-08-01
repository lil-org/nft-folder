import 'package:flutter/foundation.dart';

@immutable
class Item {
  final String name;
  final String address;
  final String abId;

  const Item({required this.name, required this.address, required this.abId});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String,
      address: json['address'] as String,
      abId: json['abId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'abId': abId,
    };
  }
}