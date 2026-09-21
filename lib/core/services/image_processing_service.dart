import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../data/models/compression_config.dart';
import '../../data/models/crop_config.dart';
import '../../data/models/resize_config.dart';
import '../errors/app_exceptions.dart';
import '../utils/image_utils.dart';

class ProcessedImageResult {
  final Uint8List bytes;
  final int originalSize;
  final int outputSize;
  final int originalWidth;
  final int originalHeight;
  final int outputWidth;
  final int outputHeight;
  final String format;
  final int quality;

  const ProcessedImageResult({
    required this.bytes,
    required this.originalSize,
    required this.outputSize,
    required this.originalWidth,
    required this.originalHeight,
    required this.outputWidth,
    required this.outputHeight,
    required this.format,
    required this.quality,
  });
}

class ImageProcessingService extends GetxService {
  Future<ImageProcessingService> init() async {
    return this;
  }

  /// Extracts image dimensions and file size without heavy processing
  Future<({int width, int height, int sizeBytes, String format})> getImageInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const AppException('File not found');
    }

    final bytes = await file.readAsBytes();
    final sizeBytes = bytes.length;
    final format = ImageUtils.inferFormat(filePath);

    final decoded = await compute(_decodeInfoIsolate, bytes);
    if (decoded == null) {
      throw const UnsupportedFormatException('Unable to decode image metadata.');
    }

    return (
      width: decoded.width,
      height: decoded.height,
      sizeBytes: sizeBytes,
      format: format,
    );
  }

  /// Compresses an image with either Quality mode or Target Size mode
  Future<ProcessedImageResult> compressImage({
    required String inputPath,
    required CompressionConfig config,
  }) async {
    final file = File(inputPath);
    final originalBytes = await file.readAsBytes();

    final result = await compute(_compressImageIsolate, {
      'bytes': originalBytes,
      'mode': config.mode.name,
      'quality': config.quality,
      'targetSizeBytes': config.targetSizeBytes,
      'outputFormat': config.outputFormat,
      'removeMetadata': config.removeMetadata,
      'maxWidth': config.maxWidth,
      'maxHeight': config.maxHeight,
    });

    if (result == null) {
      throw const CompressionException();
    }

    return result;
  }

  /// Resizes an image based on dimensions, percentage, or preset
  Future<ProcessedImageResult> resizeImage({
    required String inputPath,
    required ResizeConfig config,
  }) async {
    final file = File(inputPath);
    final originalBytes = await file.readAsBytes();

    final result = await compute(_resizeImageIsolate, {
      'bytes': originalBytes,
      'mode': config.mode.name,
      'targetWidth': config.targetWidth,
      'targetHeight': config.targetHeight,
      'percentage': config.percentage,
      'maintainAspectRatio': config.maintainAspectRatio,
      'outputFormat': config.outputFormat,
      'quality': config.quality,
    });

    if (result == null) {
      throw const CompressionException('Failed to resize image.');
    }

    return result;
  }

  /// Converts format of an image
  Future<ProcessedImageResult> convertFormat({
    required String inputPath,
    required String targetFormat,
    int quality = 90,
    bool removeMetadata = true,
  }) async {
    final file = File(inputPath);
    final originalBytes = await file.readAsBytes();

    final result = await compute(_convertFormatIsolate, {
      'bytes': originalBytes,
      'targetFormat': targetFormat,
      'quality': quality,
      'removeMetadata': removeMetadata,
    });

    if (result == null) {
      throw const CompressionException('Failed to convert image format.');
    }

    return result;
  }

  /// Crops, rotates, and flips an image
  Future<ProcessedImageResult> transformCrop({
    required String inputPath,
    required CropTransformConfig config,
  }) async {
    final file = File(inputPath);
    final originalBytes = await file.readAsBytes();

    final result = await compute(_transformCropIsolate, {
      'bytes': originalBytes,
      'rotationDegrees': config.rotationDegrees,
      'flipHorizontal': config.flipHorizontal,
      'flipVertical': config.flipVertical,
      'cropX': config.cropX,
      'cropY': config.cropY,
      'cropWidth': config.cropWidth,
      'cropHeight': config.cropHeight,
      'outputFormat': config.outputFormat,
      'quality': config.quality,
    });

    if (result == null) {
      throw const CompressionException('Failed to transform image.');
    }

    return result;
  }
}

// -----------------------------------------------------------------------------
// ISOLATE WORKERS (Compute pure Dart image transformations in background)
// -----------------------------------------------------------------------------

({int width, int height})? _decodeInfoIsolate(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  return (width: image.width, height: image.height);
}

ProcessedImageResult? _compressImageIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final mode = params['mode'] as String;
  final requestedQuality = params['quality'] as int;
  final targetSizeBytes = params['targetSizeBytes'] as int?;
  final outputFormat = (params['outputFormat'] as String).toUpperCase();
  final maxWidth = params['maxWidth'] as int?;
  final maxHeight = params['maxHeight'] as int?;

  var image = img.decodeImage(bytes);
  if (image == null) return null;

  // 1. Normalize orientation (EXIF)
  image = img.bakeOrientation(image);

  final origWidth = image.width;
  final origHeight = image.height;
  final origSize = bytes.length;

  // Optional resize constraints
  if (maxWidth != null || maxHeight != null) {
    image = img.copyResize(
      image,
      width: maxWidth,
      height: maxHeight,
      maintainAspect: true,
    );
  }

  Uint8List outputBytes;
  int finalQuality = requestedQuality;

  if (mode == 'targetSize' && targetSizeBytes != null && targetSizeBytes > 0) {
    // -------------------------------------------------------------------------
    // Target-Size Compression Algorithm (Binary Search)
    // -------------------------------------------------------------------------
    var currentImage = image;
    int minQuality = 5;
    int maxQuality = 98;
    int bestQuality = 80;
    Uint8List? bestBytes;
    int bestDiff = 999999999;

    // First attempt binary search on quality
    for (int iter = 0; iter < 7; iter++) {
      final midQuality = (minQuality + maxQuality) ~/ 2;
      final encoded = _encodeImage(currentImage, outputFormat, midQuality);

      if (encoded.length <= targetSizeBytes) {
        bestBytes = encoded;
        bestQuality = midQuality;
        // Try higher quality to get closest to target size
        minQuality = midQuality + 1;
      } else {
        // Exceeded target, search lower quality
        maxQuality = midQuality - 1;
      }
    }

    // If lowest quality (minQuality) is still larger than target, iteratively downscale
    if (bestBytes == null || bestBytes.length > targetSizeBytes) {
      double scale = 0.9;
      while (scale >= 0.2) {
        final scaledW = (origWidth * scale).round();
        final scaledH = (origHeight * scale).round();
        final scaledImage = img.copyResize(image, width: scaledW, height: scaledH);

        for (int q in [70, 50, 30, 15, 5]) {
          final encoded = _encodeImage(scaledImage, outputFormat, q);
          if (encoded.length <= targetSizeBytes) {
            bestBytes = encoded;
            bestQuality = q;
            currentImage = scaledImage;
            break;
          }
          final diff = (encoded.length - targetSizeBytes).abs();
          if (diff < bestDiff) {
            bestDiff = diff;
            bestBytes = encoded;
            bestQuality = q;
            currentImage = scaledImage;
          }
        }

        if (bestBytes != null && bestBytes.length <= targetSizeBytes) {
          break;
        }
        scale -= 0.15;
      }
    }

    outputBytes = bestBytes ?? _encodeImage(currentImage, outputFormat, 20);
    finalQuality = bestQuality;
    image = currentImage;
  } else {
    // -------------------------------------------------------------------------
    // Standard Quality Compression
    // -------------------------------------------------------------------------
    outputBytes = _encodeImage(image, outputFormat, requestedQuality);
  }

  return ProcessedImageResult(
    bytes: outputBytes,
    originalSize: origSize,
    outputSize: outputBytes.length,
    originalWidth: origWidth,
    originalHeight: origHeight,
    outputWidth: image.width,
    outputHeight: image.height,
    format: outputFormat,
    quality: finalQuality,
  );
}

ProcessedImageResult? _resizeImageIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final targetWidth = params['targetWidth'] as int?;
  final targetHeight = params['targetHeight'] as int?;
  final percentage = params['percentage'] as double?;
  final maintainAspectRatio = params['maintainAspectRatio'] as bool? ?? true;
  final outputFormat = (params['outputFormat'] as String? ?? 'JPG').toUpperCase();
  final quality = params['quality'] as int? ?? 85;

  var image = img.decodeImage(bytes);
  if (image == null) return null;

  image = img.bakeOrientation(image);
  final origWidth = image.width;
  final origHeight = image.height;
  final origSize = bytes.length;

  int newW = origWidth;
  int newH = origHeight;

  if (percentage != null && percentage > 0) {
    final scale = percentage > 1.0 ? percentage / 100.0 : percentage;
    newW = (origWidth * scale).round().clamp(1, 20000);
    newH = (origHeight * scale).round().clamp(1, 20000);
  } else if (targetWidth != null && targetHeight != null) {
    newW = targetWidth;
    newH = targetHeight;
  } else if (targetWidth != null) {
    newW = targetWidth;
    if (maintainAspectRatio) {
      newH = (targetWidth / (origWidth / origHeight)).round();
    }
  } else if (targetHeight != null) {
    newH = targetHeight;
    if (maintainAspectRatio) {
      newW = (targetHeight * (origWidth / origHeight)).round();
    }
  }

  final resized = img.copyResize(
    image,
    width: newW,
    height: newH,
    maintainAspect: maintainAspectRatio,
  );

  final outputBytes = _encodeImage(resized, outputFormat, quality);

  return ProcessedImageResult(
    bytes: outputBytes,
    originalSize: origSize,
    outputSize: outputBytes.length,
    originalWidth: origWidth,
    originalHeight: origHeight,
    outputWidth: resized.width,
    outputHeight: resized.height,
    format: outputFormat,
    quality: quality,
  );
}

ProcessedImageResult? _convertFormatIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final targetFormat = (params['targetFormat'] as String).toUpperCase();
  final quality = params['quality'] as int? ?? 90;

  var image = img.decodeImage(bytes);
  if (image == null) return null;

  image = img.bakeOrientation(image);
  final origWidth = image.width;
  final origHeight = image.height;
  final origSize = bytes.length;

  final outputBytes = _encodeImage(image, targetFormat, quality);

  return ProcessedImageResult(
    bytes: outputBytes,
    originalSize: origSize,
    outputSize: outputBytes.length,
    originalWidth: origWidth,
    originalHeight: origHeight,
    outputWidth: origWidth,
    outputHeight: origHeight,
    format: targetFormat,
    quality: quality,
  );
}

ProcessedImageResult? _transformCropIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final rotation = params['rotationDegrees'] as int? ?? 0;
  final flipH = params['flipHorizontal'] as bool? ?? false;
  final flipV = params['flipVertical'] as bool? ?? false;
  final cropX = params['cropX'] as int?;
  final cropY = params['cropY'] as int?;
  final cropW = params['cropWidth'] as int?;
  final cropH = params['cropHeight'] as int?;
  final outputFormat = (params['outputFormat'] as String? ?? 'JPG').toUpperCase();
  final quality = params['quality'] as int? ?? 90;

  var image = img.decodeImage(bytes);
  if (image == null) return null;

  image = img.bakeOrientation(image);
  final origWidth = image.width;
  final origHeight = image.height;
  final origSize = bytes.length;

  // Rotation
  if (rotation == 90 || rotation == 180 || rotation == 270) {
    image = img.copyRotate(image, angle: rotation);
  }

  // Flip
  if (flipH) {
    image = img.copyFlip(image, direction: img.FlipDirection.horizontal);
  }
  if (flipV) {
    image = img.copyFlip(image, direction: img.FlipDirection.vertical);
  }

  // Crop
  if (cropX != null && cropY != null && cropW != null && cropH != null) {
    final clX = cropX.clamp(0, image.width - 1);
    final clY = cropY.clamp(0, image.height - 1);
    final clW = cropW.clamp(1, image.width - clX);
    final clH = cropH.clamp(1, image.height - clY);
    image = img.copyCrop(image, x: clX, y: clY, width: clW, height: clH);
  }

  final outputBytes = _encodeImage(image, outputFormat, quality);

  return ProcessedImageResult(
    bytes: outputBytes,
    originalSize: origSize,
    outputSize: outputBytes.length,
    originalWidth: origWidth,
    originalHeight: origHeight,
    outputWidth: image.width,
    outputHeight: image.height,
    format: outputFormat,
    quality: quality,
  );
}

Uint8List _encodeImage(img.Image image, String format, int quality) {
  switch (format) {
    case 'PNG':
      return Uint8List.fromList(img.encodePng(image, level: 6));
    case 'WEBP':
      return Uint8List.fromList(img.encodeWebP(image));
    case 'JPG':
    case 'JPEG':
    default:
      return Uint8List.fromList(img.encodeJpg(image, quality: quality.clamp(1, 100)));
  }
}


