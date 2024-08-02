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

  Future<String> _generateHtmlContent() async {
    final String id = item.address + item.abId;
    final String tokensJson = await rootBundle.loadString('assets/items/tokens/$id.json');
    final String scriptJson = await rootBundle.loadString('assets/items/scripts/$id.json');
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
        <h1>${item.name} $scriptJson</h1>
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