class Script {
  final String address;
  final String name;
  final String abId;
  final String value;
  final String kind;

  Script({
    required this.address,
    required this.name,
    required this.abId,
    required this.value,
    required this.kind,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      address: json['address'],
      name: json['name'],
      abId: json['abId'],
      value: json['value'],
      kind: json['kind'],
    );
  }
}

class BundledTokens {
  final List<BundledTokenItem> items;

  BundledTokens({required this.items});

  factory BundledTokens.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<BundledTokenItem> items = itemsList.map((i) => BundledTokenItem.fromJson(i)).toList();
    return BundledTokens(items: items);
  }
}

class BundledTokenItem {
  final String id;
  final String hash;

  BundledTokenItem({required this.id, required this.hash});

  factory BundledTokenItem.fromJson(Map<String, dynamic> json) {
    return BundledTokenItem(
      id: json['id'],
      hash: json['hash'],
    );
  }
}