class ConvertConfig {
  final String targetFormat; // 'JPG', 'PNG', 'WEBP'
  final int quality; // 10 to 100 (for JPG & WEBP)
  final bool removeMetadata;

  const ConvertConfig({
    required this.targetFormat,
    this.quality = 90,
    this.removeMetadata = true,
  });

  ConvertConfig copyWith({
    String? targetFormat,
    int? quality,
    bool? removeMetadata,
  }) {
    return ConvertConfig(
      targetFormat: targetFormat ?? this.targetFormat,
      quality: quality ?? this.quality,
      removeMetadata: removeMetadata ?? this.removeMetadata,
    );
  }
}
