enum ResizeMode {
  dimensions,
  percentage,
  preset,
}

class ResizeConfig {
  final ResizeMode mode;
  final int? targetWidth;
  final int? targetHeight;
  final double percentage; // e.g. 0.5 for 50%
  final String? presetLabel;
  final bool maintainAspectRatio;
  final String outputFormat;
  final int quality;

  const ResizeConfig({
    this.mode = ResizeMode.dimensions,
    this.targetWidth,
    this.targetHeight,
    this.percentage = 0.5,
    this.presetLabel,
    this.maintainAspectRatio = true,
    this.outputFormat = 'JPG',
    this.quality = 85,
  });

  ResizeConfig copyWith({
    ResizeMode? mode,
    int? targetWidth,
    int? targetHeight,
    double? percentage,
    String? presetLabel,
    bool? maintainAspectRatio,
    String? outputFormat,
    int? quality,
  }) {
    return ResizeConfig(
      mode: mode ?? this.mode,
      targetWidth: targetWidth ?? this.targetWidth,
      targetHeight: targetHeight ?? this.targetHeight,
      percentage: percentage ?? this.percentage,
      presetLabel: presetLabel ?? this.presetLabel,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      outputFormat: outputFormat ?? this.outputFormat,
      quality: quality ?? this.quality,
    );
  }
}
