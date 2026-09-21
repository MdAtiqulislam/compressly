import 'package:path/path.dart' as p;

class FileNameGenerator {
  FileNameGenerator._();

  /// Generates clean output filename according to operation and format
  static String generateOutputFileName({
    required String originalPath,
    required String operation, // 'compressed', 'resized', 'converted', 'cropped'
    required String targetExtension, // 'jpg', 'png', 'webp'
    int? width,
    int? height,
    int? batchIndex,
  }) {
    final baseName = p.basenameWithoutExtension(originalPath);
    final ext = targetExtension.toLowerCase().replaceAll('.', '');
    final cleanExt = ext == 'jpeg' ? 'jpg' : ext;

    if (batchIndex != null) {
      final indexStr = (batchIndex + 1).toString().padLeft(3, '0');
      return '${baseName}_${indexStr}_$operation.$cleanExt';
    }

    if (operation == 'resized' && width != null && height != null) {
      return '${baseName}_${width}x$height.$cleanExt';
    }

    return '${baseName}_$operation.$cleanExt';
  }
}
