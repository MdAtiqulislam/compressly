import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ShareService extends GetxService {
  Future<ShareService> init() async {
    return this;
  }

  /// Shares a single file using the native OS share sheet
  Future<void> shareFile({
    required String filePath,
    String? text,
    String? subject,
  }) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles(
      [xFile],
      text: text,
      subject: subject ?? 'Compressed with Compressly',
    );
  }

  /// Shares multiple files using the native OS share sheet
  Future<void> shareMultipleFiles({
    required List<String> filePaths,
    String? text,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      xFiles,
      text: text,
      subject: 'Compressed with Compressly',
    );
  }

  /// Shares app promotion message
  Future<void> shareApp() async {
    await Share.share(
      'Check out Compressly - the fast, privacy-first offline image compressor and converter! https://compressly.app',
      subject: 'Compressly - Smart Image Utility',
    );
  }
}
