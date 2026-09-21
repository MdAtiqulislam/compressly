import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/compression_history.dart';
import '../constants/app_constants.dart';

class HistoryService extends GetxService {
  late SharedPreferences _prefs;

  final RxList<CompressionHistory> historyList = <CompressionHistory>[].obs;
  final RxInt totalBytesSaved = 0.obs;
  final RxInt totalImagesCompressed = 0.obs;

  Future<HistoryService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadHistory();
    return this;
  }

  void _loadHistory() {
    final rawJson = _prefs.getString(AppConstants.keyHistoryList);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        final items = decoded
            .map((item) => CompressionHistory.fromJson(item as Map<String, dynamic>))
            .toList();
        historyList.assignAll(items);
      } catch (_) {
        historyList.clear();
      }
    }

    totalBytesSaved.value = _prefs.getInt(AppConstants.keyTotalBytesSaved) ?? _calculateTotalSaved();
    totalImagesCompressed.value = _prefs.getInt(AppConstants.keyTotalImagesCompressed) ?? historyList.length;
  }

  int _calculateTotalSaved() {
    return historyList.fold<int>(0, (sum, item) => sum + item.bytesSaved);
  }

  Future<void> addHistory(CompressionHistory item) async {
    historyList.insert(0, item);
    totalBytesSaved.value += item.bytesSaved;
    totalImagesCompressed.value += 1;

    await _saveHistory();
  }

  Future<void> deleteHistory(String id) async {
    final index = historyList.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = historyList[index];
      // Optionally delete physical file if wanted
      try {
        final file = File(item.outputPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      historyList.removeAt(index);
      await _saveHistory();
    }
  }

  Future<void> clearAllHistory() async {
    historyList.clear();
    await _prefs.remove(AppConstants.keyHistoryList);
  }

  Future<void> _saveHistory() async {
    final encoded = jsonEncode(historyList.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.keyHistoryList, encoded);
    await _prefs.setInt(AppConstants.keyTotalBytesSaved, totalBytesSaved.value);
    await _prefs.setInt(AppConstants.keyTotalImagesCompressed, totalImagesCompressed.value);
  }
}
