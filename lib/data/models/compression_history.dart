class CompressionHistory {
  final String id;
  final String originalPath;
  final String outputPath;
  final String fileName;
  final int originalSize;
  final int compressedSize;
  final int originalWidth;
  final int originalHeight;
  final int outputWidth;
  final int outputHeight;
  final String inputFormat;
  final String outputFormat;
  final String operation;
  final DateTime createdAt;

  const CompressionHistory({
    required this.id,
    required this.originalPath,
    required this.outputPath,
    required this.fileName,
    required this.originalSize,
    required this.compressedSize,
    required this.originalWidth,
    required this.originalHeight,
    required this.outputWidth,
    required this.outputHeight,
    required this.inputFormat,
    required this.outputFormat,
    required this.operation,
    required this.createdAt,
  });

  int get bytesSaved => (originalSize - compressedSize).clamp(0, originalSize);

  double get savingsPercentage {
    if (originalSize <= 0 || compressedSize >= originalSize) return 0.0;
    return ((originalSize - compressedSize) / originalSize) * 100.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'outputPath': outputPath,
        'fileName': fileName,
        'originalSize': originalSize,
        'compressedSize': compressedSize,
        'originalWidth': originalWidth,
        'originalHeight': originalHeight,
        'outputWidth': outputWidth,
        'outputHeight': outputHeight,
        'inputFormat': inputFormat,
        'outputFormat': outputFormat,
        'operation': operation,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CompressionHistory.fromJson(Map<String, dynamic> json) =>
      CompressionHistory(
        id: json['id'] as String,
        originalPath: json['originalPath'] as String,
        outputPath: json['outputPath'] as String,
        fileName: json['fileName'] as String,
        originalSize: (json['originalSize'] as num).toInt(),
        compressedSize: (json['compressedSize'] as num).toInt(),
        originalWidth: (json['originalWidth'] as num).toInt(),
        originalHeight: (json['originalHeight'] as num).toInt(),
        outputWidth: (json['outputWidth'] as num).toInt(),
        outputHeight: (json['outputHeight'] as num).toInt(),
        inputFormat: json['inputFormat'] as String,
        outputFormat: json['outputFormat'] as String,
        operation: json['operation'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
