import 'dart:convert';
import 'package:flutter/services.dart';
import 'item.dart';
import 'dart:math';

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

Future<Map<String, String>> generateHtmlContent(Item item) async {
  final String id = item.address + item.abId;
  final String tokensJsonString = await rootBundle.loadString('assets/items/tokens/$id.json');
  final BundledTokens bundledTokens = BundledTokens.fromJson(json.decode(tokensJsonString));
  final String scriptJsonString = await rootBundle.loadString('assets/items/scripts/$id.json');
  final Script script = Script.fromJson(json.decode(scriptJsonString));
  final String lib = (script.kind == "js" || script.kind == "svg") ? "" : await rootBundle.loadString('assets/items/libs/${script.kind}.js');

  final random = Random();
  final token = bundledTokens.items[random.nextInt(bundledTokens.items.length)];
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
  return {
    'html': html,
    'tokenId': tokenid,
  };
}