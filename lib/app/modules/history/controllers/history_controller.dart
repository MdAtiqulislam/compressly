import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../data/models/compression_history.dart';

class HistoryController extends GetxController {
  final HistoryService historyService = Get.find<HistoryService>();
  final ShareService shareService = Get.find<ShareService>();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  List<CompressionHistory> get filteredHistory {
    if (searchQuery.value.trim().isEmpty) {
      return historyService.historyList;
    }
    final q = searchQuery.value.toLowerCase();
    return historyService.historyList.where((item) {
      return item.fileName.toLowerCase().contains(q) ||
          item.operation.toLowerCase().contains(q) ||
          item.outputFormat.toLowerCase().contains(q);
    }).toList();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> shareItem(CompressionHistory item) async {
    await shareService.shareFile(filePath: item.outputPath);
  }

  Future<void> deleteItem(CompressionHistory item) async {
    await historyService.deleteHistory(item.id);
  }

  Future<void> confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will delete all past compression records from history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await historyService.clearAllHistory();
    }
  }
}
