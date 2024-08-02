import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'item.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

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

class SampleItemDetailsView extends StatelessWidget {
  final Item item;

  const SampleItemDetailsView({super.key, required this.item});

  static const routeName = '/sample_item';

  Future<String> _generateHtmlContent() async {
    final String id = item.address + item.abId;
    final String tokensJsonString = await rootBundle.loadString('assets/items/tokens/$id.json');
    final BundledTokens bundledTokens = BundledTokens.fromJson(json.decode(tokensJsonString));
    final String scriptJsonString = await rootBundle.loadString('assets/items/scripts/$id.json');
    final Script script = Script.fromJson(json.decode(scriptJsonString));
    // final String libContent = await rootBundle.loadString('assets/items/lib/${item.address}${item.abId}.js');

    final random = Random();
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            background-color: rgb($r, $g, $b);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
          }
          h1 {
            color: white;
          }
        </style>
      </head>
      <body>
        <h1>${item.name} ${script.name} ${script.kind} ${bundledTokens.items.length}</h1>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: _generateHtmlContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WebViewWidget(
              controller: WebViewController()
                ..loadHtmlString(snapshot.data!)
                ..setJavaScriptMode(JavaScriptMode.unrestricted),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}