import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  String _getRandomHtmlFile() {
    final random = Random();
    final fileNumber = random.nextInt(5) + 1;
    return 'assets/htmls/$fileNumber.html';
  }

  @override
  Widget build(BuildContext context) {
    final randomHtmlFile = _getRandomHtmlFile();

    return Scaffold(
      body: WebViewWidget(
        controller: WebViewController()
          ..loadFlutterAsset(randomHtmlFile)
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
