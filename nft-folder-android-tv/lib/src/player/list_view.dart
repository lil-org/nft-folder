import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'item_repository.dart';
import 'item_view.dart';

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final ItemRepository _itemRepository = ItemRepository();
  int _focusedIndex = 0;
  final FocusNode _gridFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  static const int crossAxisCount = 5;

  @override
  void initState() {
    super.initState();
    _loadItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_gridFocusNode);
    });
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    await _itemRepository.loadItems();
    setState(() {});
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      int itemCount = _itemRepository.items.length;
      int oldFocusedIndex = _focusedIndex;
      int currentRow = _focusedIndex ~/ crossAxisCount;
      int currentCol = _focusedIndex % crossAxisCount;
      int lastRowItemCount = itemCount % crossAxisCount;
      if (lastRowItemCount == 0) lastRowItemCount = crossAxisCount;
      int totalRows = (itemCount / crossAxisCount).ceil();

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            if (currentRow > 0) {
              _focusedIndex -= crossAxisCount;
            } else {
              int newRow = totalRows - 1;
              while (newRow * crossAxisCount + currentCol >= itemCount) {
                newRow--;
              }
              _focusedIndex = newRow * crossAxisCount + currentCol;
            }
          });
          break;
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            if (currentRow < totalRows - 1 && _focusedIndex + crossAxisCount < itemCount) {
              _focusedIndex += crossAxisCount;
            } else {
              _focusedIndex = currentCol;
            }
          });
          break;
        case LogicalKeyboardKey.arrowLeft:
          setState(() {
            if (currentCol > 0) {
              _focusedIndex--;
            } else {
              int rightmostCol = (currentRow == totalRows - 1) ? (lastRowItemCount - 1) : (crossAxisCount - 1);
              _focusedIndex = currentRow * crossAxisCount + rightmostCol;
            }
          });
          break;
        case LogicalKeyboardKey.arrowRight:
          setState(() {
            if (currentCol < crossAxisCount - 1 && _focusedIndex < itemCount - 1) {
              _focusedIndex++;
            } else {
              _focusedIndex = currentRow * crossAxisCount;
            }
          });
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _navigateToItemDetails(_itemRepository.items[_focusedIndex]);
          break;
        default:
          break;
      }

      if (_focusedIndex != oldFocusedIndex) {
        _scrollToFocusedItem();
      }
    }
  }

  void _scrollToFocusedItem() {
    final itemHeight = MediaQuery.of(context).size.width / crossAxisCount * (1 / 1.25);
    final itemsPerColumn = (MediaQuery.of(context).size.height / itemHeight).floor();
    final rowIndex = _focusedIndex ~/ crossAxisCount;
    final visibleRowsStart = _scrollController.offset ~/ itemHeight;
    final visibleRowsEnd = visibleRowsStart + itemsPerColumn - 1;

    if (rowIndex < visibleRowsStart || rowIndex > visibleRowsEnd) {
      final targetScroll = rowIndex * itemHeight;
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToItemDetails(dynamic item) {
    Navigator.restorablePushNamed(
      context,
      SampleItemDetailsView.routeName,
      arguments: item.toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⌐◨-◨'),
      ),
      body: KeyboardListener(
        focusNode: _gridFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.25,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _itemRepository.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = _itemRepository.items[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _focusedIndex == index ? Colors.blue : Colors.transparent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    foregroundImage: AssetImage('assets/items/covers/${item.address}${item.abId}.webp'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
