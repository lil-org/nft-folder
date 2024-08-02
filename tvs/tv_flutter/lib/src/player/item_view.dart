import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'item.dart';
import 'generator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
    final String lib = (script.kind == "js" || script.kind == "svg") ? "" : await rootBundle.loadString('assets/items/libs/${script.kind}.js');

    final token = bundledTokens.items.first;
    final hash = token.hash;
    final tokenid = token.id;

    String tokenData;
    if (script.address == "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a") {
      tokenData = 'let tokenData = {"tokenId": "$tokenid", "hashes": ["$hash"]}';
    } else {
      tokenData = 'let tokenData = {"tokenId": "$tokenid", "hash": "$hash"}';
    }

    const viewport = '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>';

    String html;
    switch (script.kind) {
      case 'svg':
        html = '''
          <html>
          <head>
            $viewport
            <meta charset="utf-8">
            <style type="text/css">
              body {
                min-height: 100%;
                margin: 0;
                padding: 0;
              }
              svg {
                padding: 0;
                margin: auto;
                display: block;
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
              }
            </style>
          </head>
          <body></body>
          <script>$tokenData</script>
          <script>${script.value}</script>
          </html>
        ''';
        break;
      case 'js':
        html = '''
          <html>
          <head>
            $viewport
            <meta charset="utf-8">
            <script>$tokenData</script>
            <style type="text/css">
              body {
                margin: 0;
                padding: 0;
              }
              canvas {
                padding: 0;
                margin: auto;
                display: block;
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
              }
            </style>
          </head>
          <body>
            <canvas></canvas>
            <script>${script.value}</script>
          </body>
          </html>
        ''';
        break;
      case 'p5js100':
      case 'p5js190':
        html = '''
          <html>
          <head>
            $viewport
            <meta charset="utf-8">
            <script>$lib</script>
            <script>$tokenData</script>
            <script>${script.value}</script>
            <style type="text/css">
              html {
                height: 100%;
              }
              body {
                min-height: 100%;
                margin: 0;
                padding: 0;
              }
              canvas {
                padding: 0;
                margin: auto;
                display: block;
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
              }
            </style>
          </head>
          </html>
        ''';
        break;
      case 'paper':
      case 'twemoji':
        html = '''
          <html>
          <head>
            $viewport
            <meta charset="utf-8"/>
            <script>$lib</script>
            <script>$tokenData</script>
            <script>${script.value}</script>
            <style type="text/css">
              html {
                height: 100%;
              }
              body {
                min-height: 100%;
                margin: 0;
                padding: 0;
              }
              canvas {
                padding: 0;
                margin: auto;
                display: block;
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
              }
            </style>
          </head>
          </html>
        ''';
        break;
      case 'three':
        html = '''
          <html>
            <head>
              $viewport
              <script>$lib</script>
              <meta charset="utf-8">
              <style type="text/css">
                body {
                  margin: 0;
                  padding: 0;
                }
                canvas {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            <body></body>
            <script>$tokenData</script>
            <script>${script.value}</script>
          </html>
        ''';
        break;
      case 'regl':
        html = '''
          <html>
            <head>
              $viewport
              <script>$lib</script>
              <script>$tokenData</script>
              <meta charset="utf-8">
              <style type="text/css">
                body {
                  margin: 0;
                  padding: 0;
                }
                canvas {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            <body>
              <script>${script.value}</script>
            </body>
          </html>
        ''';
        break;
      case 'tone':
        html = '''
          <html>
            <head>
              $viewport
              <script>$lib</script>
              <meta charset="utf-8">
              <style type="text/css">
                body {
                  margin: 0;
                  padding: 0;
                }
                canvas {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            <body>
              <canvas></canvas>
            </body>
            <script>$tokenData</script>
            <script>${script.value}</script>
          </html>
        ''';
        break;
      default:
        html = '<html><body>hmm</body></html>';
    }
    return html;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: _generateHtmlContent(),
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