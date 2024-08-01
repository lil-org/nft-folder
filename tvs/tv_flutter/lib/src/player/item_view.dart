import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'item.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class SampleItemDetailsView extends StatelessWidget {
  final Item item;

  const SampleItemDetailsView({super.key, required this.item});

  static const routeName = '/sample_item';

  String _generateHtmlContent() {
    // TODO: load content

    // final String tokensJson = await rootBundle.loadString('assets/items/tokens.json');
    // final String scriptJson = await rootBundle.loadString('assets/items/script.json');
    // final String libContent = await rootBundle.loadString('assets/items/lib/${item.address}${item.abId}.js');

    // TODO: build html

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
        <h1>${item.name}</h1>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final randomHtml = _generateHtmlContent();
    return Scaffold(
      body: WebViewWidget(
        controller: WebViewController()
          ..loadHtmlString(randomHtml)
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}