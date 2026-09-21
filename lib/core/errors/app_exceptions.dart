class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, [this.details]);

  @override
  String toString() => message;
}

class ImagePickerException extends AppException {
  const ImagePickerException(super.message, [super.details]);
}

class UnsupportedFormatException extends AppException {
  const UnsupportedFormatException([super.message = 'This image format is not supported.']);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([super.message = 'Photo access is required to select images.']);
}

class CompressionException extends AppException {
  const CompressionException([super.message = 'Unable to compress this image. Please try another image.']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Unable to save the image. Please check available storage.']);
}

class TargetSizeImpossibleException extends AppException {
  final int achievedBytes;
  final int requestedBytes;

  const TargetSizeImpossibleException({
    required this.achievedBytes,
    required this.requestedBytes,
    String message = 'Target size could not be reached with acceptable quality. Try a larger target size.',
  }) : super(message);
}
