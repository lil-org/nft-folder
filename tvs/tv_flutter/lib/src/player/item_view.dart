import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  String _generateRandomColorHtml() {
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
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
          }
        </style>
      </head>
      <body></body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final randomHtml = _generateRandomColorHtml();

    return Scaffold(
      body: WebViewWidget(
        controller: WebViewController()
          ..loadHtmlString(randomHtml)
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
