import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService extends GetxService {
  late Directory _appDocDir;
  late Directory _appTempDir;
  late Directory _outputDir;

  Future<StorageService> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _appTempDir = await getTemporaryDirectory();

    final outputPath = p.join(_appDocDir.path, 'Compressly');
    _outputDir = Directory(outputPath);
    if (!await _outputDir.exists()) {
      await _outputDir.create(recursive: true);
    }

    return this;
  }

  Directory get outputDirectory => _outputDir;
  Directory get tempDirectory => _appTempDir;

  /// Saves image bytes to the Compressly output folder
  Future<File> saveImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    var filePath = p.join(_outputDir.path, fileName);
    var file = File(filePath);

    // If file with same name exists, append timestamp
    if (await file.exists()) {
      final nameWithoutExt = p.basenameWithoutExtension(fileName);
      final ext = p.extension(fileName);
      final uniqueName = '${nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch}$ext';
      filePath = p.join(_outputDir.path, uniqueName);
      file = File(filePath);
    }

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Calculates total size of temporary and output files
  Future<({int tempBytes, int outputBytes, int totalBytes})> calculateStorageUsage() async {
    int tempSize = 0;
    int outputSize = 0;

    try {
      if (await _appTempDir.exists()) {
        await for (final file in _appTempDir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            tempSize += await file.length();
          }
        }
      }
    } catch (_) {}

    try {
      if (await _outputDir.exists()) {
        await for (final file in _outputDir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            outputSize += await file.length();
          }
        }
      }
    } catch (_) {}

    return (
      tempBytes: tempSize,
      outputBytes: outputSize,
      totalBytes: tempSize + outputSize,
    );
  }

  /// Clears temporary cache files
  Future<void> clearTemporaryCache() async {
    try {
      if (await _appTempDir.exists()) {
        final entities = _appTempDir.listSync(followLinks: false);
        for (final entity in entities) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
