import 'package:flutter/foundation.dart';

@immutable
class Item {
  final String name;
  final String address;
  final String abId;
  final bool? didNotWorkOnProjector;

  const Item({
    required this.name,
    required this.address,
    required this.abId,
    this.didNotWorkOnProjector,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String,
      address: json['address'] as String,
      abId: json['abId'] as String,
      didNotWorkOnProjector: json['didNotWorkOnProjector'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'abId': abId,
      if (didNotWorkOnProjector != null) 'didNotWorkOnProjector': didNotWorkOnProjector,
    };
  }
}