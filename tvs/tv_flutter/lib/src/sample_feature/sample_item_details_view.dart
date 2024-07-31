import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:math';

class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  String _getRandomColor() {
    final random = Random();
    return '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final randomColor = _getRandomColor();
    final htmlContent = '''
      <html>
        <body style="background-color: $randomColor;">
        </body>
      </html>
    ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('webview'),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(
            Uri.dataFromString(
              htmlContent,
              mimeType: 'text/html',
              encoding: utf8,
            ),
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
