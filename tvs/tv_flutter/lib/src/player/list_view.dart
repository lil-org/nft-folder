import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _itemRepository.loadItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⌐◨-◨'),
      ),
      body: ListView.builder(
        restorationId: 'sampleItemListView',
        itemCount: _itemRepository.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _itemRepository.items[index];

          return ListTile(
            title: Text(item.name),
            leading: CircleAvatar(
              foregroundImage: AssetImage('assets/items/covers/${item.address}${item.abId}.webp'),
            ),
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                SampleItemDetailsView.routeName,
                arguments: item.toJson(),
              );
            }
          );
        },
      ),
    );
  }
}
