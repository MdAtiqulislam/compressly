enum BatchItemStatus {
  pending,
  processing,
  completed,
  failed,
}

class BatchProcessItem {
  final String id;
  final String originalPath;
  final String fileName;
  final int originalSize;
  String? outputPath;
  int? compressedSize;
  BatchItemStatus status;
  String? errorMessage;
  int? originalWidth;
  int? originalHeight;
  int? outputWidth;
  int? outputHeight;

  BatchProcessItem({
    required this.id,
    required this.originalPath,
    required this.fileName,
    required this.originalSize,
    this.outputPath,
    this.compressedSize,
    this.status = BatchItemStatus.pending,
    this.errorMessage,
    this.originalWidth,
    this.originalHeight,
    this.outputWidth,
    this.outputHeight,
  });

  int get bytesSaved {
    if (compressedSize == null || compressedSize! >= originalSize) return 0;
    return originalSize - compressedSize!;
  }

  double get savingsPercentage {
    if (compressedSize == null || originalSize <= 0 || compressedSize! >= originalSize) {
      return 0.0;
    }
    return ((originalSize - compressedSize!) / originalSize) * 100.0;
  }
}
