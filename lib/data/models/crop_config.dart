enum CropAspectRatioPreset {
  free,
  square1x1,
  ratio4x3,
  ratio3x4,
  ratio16x9,
  ratio9x16,
}

extension CropAspectRatioPresetExt on CropAspectRatioPreset {
  String get label {
    switch (this) {
      case CropAspectRatioPreset.free:
        return 'Free';
      case CropAspectRatioPreset.square1x1:
        return '1:1';
      case CropAspectRatioPreset.ratio4x3:
        return '4:3';
      case CropAspectRatioPreset.ratio3x4:
        return '3:4';
      case CropAspectRatioPreset.ratio16x9:
        return '16:9';
      case CropAspectRatioPreset.ratio9x16:
        return '9:16';
    }
  }

  double? get ratio {
    switch (this) {
      case CropAspectRatioPreset.free:
        return null;
      case CropAspectRatioPreset.square1x1:
        return 1.0;
      case CropAspectRatioPreset.ratio4x3:
        return 4.0 / 3.0;
      case CropAspectRatioPreset.ratio3x4:
        return 3.0 / 4.0;
      case CropAspectRatioPreset.ratio16x9:
        return 16.0 / 9.0;
      case CropAspectRatioPreset.ratio9x16:
        return 9.0 / 16.0;
    }
  }
}

class CropTransformConfig {
  final int rotationDegrees; // 0, 90, 180, 270
  final bool flipHorizontal;
  final bool flipVertical;
  final int? cropX;
  final int? cropY;
  final int? cropWidth;
  final int? cropHeight;
  final String outputFormat;
  final int quality;

  const CropTransformConfig({
    this.rotationDegrees = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.cropX,
    this.cropY,
    this.cropWidth,
    this.cropHeight,
    this.outputFormat = 'JPG',
    this.quality = 90,
  });

  CropTransformConfig copyWith({
    int? rotationDegrees,
    bool? flipHorizontal,
    bool? flipVertical,
    int? cropX,
    int? cropY,
    int? cropWidth,
    int? cropHeight,
    String? outputFormat,
    int? quality,
  }) {
    return CropTransformConfig(
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      cropX: cropX ?? this.cropX,
      cropY: cropY ?? this.cropY,
      cropWidth: cropWidth ?? this.cropWidth,
      cropHeight: cropHeight ?? this.cropHeight,
      outputFormat: outputFormat ?? this.outputFormat,
      quality: quality ?? this.quality,
    );
  }
}
