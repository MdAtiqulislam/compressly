enum CompressionMode {
  quality,
  targetSize,
}

class CompressionConfig {
  final CompressionMode mode;
  final int quality; // 10 to 100
  final int? targetSizeBytes; // e.g. 100 * 1024
  final String outputFormat; // 'JPG', 'PNG', 'WEBP'
  final bool removeMetadata;
  final bool maintainAspectRatio;
  final int? maxWidth;
  final int? maxHeight;

  const CompressionConfig({
    this.mode = CompressionMode.quality,
    this.quality = 80,
    this.targetSizeBytes,
    this.outputFormat = 'JPG',
    this.removeMetadata = true,
    this.maintainAspectRatio = true,
    this.maxWidth,
    this.maxHeight,
  });

  CompressionConfig copyWith({
    CompressionMode? mode,
    int? quality,
    int? targetSizeBytes,
    String? outputFormat,
    bool? removeMetadata,
    bool? maintainAspectRatio,
    int? maxWidth,
    int? maxHeight,
  }) {
    return CompressionConfig(
      mode: mode ?? this.mode,
      quality: quality ?? this.quality,
      targetSizeBytes: targetSizeBytes ?? this.targetSizeBytes,
      outputFormat: outputFormat ?? this.outputFormat,
      removeMetadata: removeMetadata ?? this.removeMetadata,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }
}
