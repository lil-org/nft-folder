import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'item.dart';
import 'generator.dart';
import 'item_repository.dart';

class SampleItemDetailsView extends StatefulWidget {
  final Item? item;

  const SampleItemDetailsView({super.key, this.item});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late Item currentItem;
  late WebViewController _controller;
  final ItemRepository _itemRepository = ItemRepository();

  @override
  void initState() {
    super.initState();
    currentItem = widget.item ?? _itemRepository.getRandomItem();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
    _loadContent();
  }

  Future<void> _loadContent() async {
    String htmlContent = await generateHtmlContent(currentItem);
    await _controller.loadHtmlString(htmlContent);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.select) {
        setState(() {
          currentItem = _itemRepository.getRandomItem();
          _loadContent();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}