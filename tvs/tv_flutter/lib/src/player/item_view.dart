import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'item.dart';
import 'generator.dart';

class SampleItemDetailsView extends StatelessWidget {
  final Item item;

  const SampleItemDetailsView({super.key, required this.item});

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: generateHtmlContent(item),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WebViewWidget(
              controller: WebViewController()
                ..loadHtmlString(snapshot.data!)
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(const Color(0x00000000)),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}