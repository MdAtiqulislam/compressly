import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum _HandleType {
  none,
  inside,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topEdge,
  bottomEdge,
  leftEdge,
  rightEdge,
}

class InteractiveCropOverlay extends StatefulWidget {
  final Rect normalizedRect; // 0.0 to 1.0 within the image
  final double? targetAspectRatio; // width / height or null for free
  final Size imageDisplaySize;
  final Offset imageOffset;
  final int rawImageWidth;
  final int rawImageHeight;
  final ValueChanged<Rect> onRectChanged;

  const InteractiveCropOverlay({
    super.key,
    required this.normalizedRect,
    this.targetAspectRatio,
    required this.imageDisplaySize,
    required this.imageOffset,
    required this.rawImageWidth,
    required this.rawImageHeight,
    required this.onRectChanged,
  });

  @override
  State<InteractiveCropOverlay> createState() => _InteractiveCropOverlayState();
}

class _InteractiveCropOverlayState extends State<InteractiveCropOverlay> {
  _HandleType _activeHandle = _HandleType.none;
  Offset? _dragStartGlobal;
  Rect? _rectStartNorm;

  static const double handleTouchRadius = 24.0;
  static const double minNormSize = 0.05; // 5% minimum size

  Rect get _screenRect {
    return Rect.fromLTWH(
      widget.imageOffset.dx + widget.normalizedRect.left * widget.imageDisplaySize.width,
      widget.imageOffset.dy + widget.normalizedRect.top * widget.imageDisplaySize.height,
      widget.normalizedRect.width * widget.imageDisplaySize.width,
      widget.normalizedRect.height * widget.imageDisplaySize.height,
    );
  }

  _HandleType _hitTest(Offset localPos) {
    final rect = _screenRect;

    // Check corners first
    if ((localPos - rect.topLeft).distance <= handleTouchRadius) return _HandleType.topLeft;
    if ((localPos - rect.topRight).distance <= handleTouchRadius) return _HandleType.topRight;
    if ((localPos - rect.bottomLeft).distance <= handleTouchRadius) return _HandleType.bottomLeft;
    if ((localPos - rect.bottomRight).distance <= handleTouchRadius) return _HandleType.bottomRight;

    // Check edges
    if ((localPos.dy - rect.top).abs() <= handleTouchRadius &&
        localPos.dx >= rect.left &&
        localPos.dx <= rect.right) {
      return _HandleType.topEdge;
    }
    if ((localPos.dy - rect.bottom).abs() <= handleTouchRadius &&
        localPos.dx >= rect.left &&
        localPos.dx <= rect.right) {
      return _HandleType.bottomEdge;
    }
    if ((localPos.dx - rect.left).abs() <= handleTouchRadius &&
        localPos.dy >= rect.top &&
        localPos.dy <= rect.bottom) {
      return _HandleType.leftEdge;
    }
    if ((localPos.dx - rect.right).abs() <= handleTouchRadius &&
        localPos.dy >= rect.top &&
        localPos.dy <= rect.bottom) {
      return _HandleType.rightEdge;
    }

    // Inside rect
    if (rect.contains(localPos)) {
      return _HandleType.inside;
    }

    return _HandleType.none;
  }

  void _onPanStart(DragStartDetails details) {
    final handle = _hitTest(details.localPosition);
    if (handle != _HandleType.none) {
      setState(() {
        _activeHandle = handle;
        _dragStartGlobal = details.localPosition;
        _rectStartNorm = widget.normalizedRect;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == _HandleType.none || _dragStartGlobal == null || _rectStartNorm == null) return;

    final dxNorm = (details.localPosition.dx - _dragStartGlobal!.dx) / widget.imageDisplaySize.width;
    final dyNorm = (details.localPosition.dy - _dragStartGlobal!.dy) / widget.imageDisplaySize.height;

    var left = _rectStartNorm!.left;
    var top = _rectStartNorm!.top;
    var right = _rectStartNorm!.right;
    var bottom = _rectStartNorm!.bottom;

    final ratio = widget.targetAspectRatio;

    switch (_activeHandle) {
      case _HandleType.inside:
        final w = right - left;
        final h = bottom - top;
        left = (left + dxNorm).clamp(0.0, 1.0 - w);
        top = (top + dyNorm).clamp(0.0, 1.0 - h);
        right = left + w;
        bottom = top + h;
        break;

      case _HandleType.topLeft:
        left = (left + dxNorm).clamp(0.0, right - minNormSize);
        top = (top + dyNorm).clamp(0.0, bottom - minNormSize);
        if (ratio != null) {
          final wPx = (right - left) * widget.rawImageWidth;
          final hPx = wPx / ratio;
          top = (bottom - (hPx / widget.rawImageHeight)).clamp(0.0, bottom - minNormSize);
        }
        break;

      case _HandleType.topRight:
        right = (right + dxNorm).clamp(left + minNormSize, 1.0);
        top = (top + dyNorm).clamp(0.0, bottom - minNormSize);
        if (ratio != null) {
          final wPx = (right - left) * widget.rawImageWidth;
          final hPx = wPx / ratio;
          top = (bottom - (hPx / widget.rawImageHeight)).clamp(0.0, bottom - minNormSize);
        }
        break;

      case _HandleType.bottomLeft:
        left = (left + dxNorm).clamp(0.0, right - minNormSize);
        bottom = (bottom + dyNorm).clamp(top + minNormSize, 1.0);
        if (ratio != null) {
          final wPx = (right - left) * widget.rawImageWidth;
          final hPx = wPx / ratio;
          bottom = (top + (hPx / widget.rawImageHeight)).clamp(top + minNormSize, 1.0);
        }
        break;

      case _HandleType.bottomRight:
        right = (right + dxNorm).clamp(left + minNormSize, 1.0);
        bottom = (bottom + dyNorm).clamp(top + minNormSize, 1.0);
        if (ratio != null) {
          final wPx = (right - left) * widget.rawImageWidth;
          final hPx = wPx / ratio;
          bottom = (top + (hPx / widget.rawImageHeight)).clamp(top + minNormSize, 1.0);
        }
        break;

      case _HandleType.topEdge:
        if (ratio == null) {
          top = (top + dyNorm).clamp(0.0, bottom - minNormSize);
        }
        break;

      case _HandleType.bottomEdge:
        if (ratio == null) {
          bottom = (bottom + dyNorm).clamp(top + minNormSize, 1.0);
        }
        break;

      case _HandleType.leftEdge:
        if (ratio == null) {
          left = (left + dxNorm).clamp(0.0, right - minNormSize);
        }
        break;

      case _HandleType.rightEdge:
        if (ratio == null) {
          right = (right + dxNorm).clamp(left + minNormSize, 1.0);
        }
        break;

      case _HandleType.none:
        break;
    }

    final newRect = Rect.fromLTRB(left, top, right, bottom);
    widget.onRectChanged(newRect);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _activeHandle = _HandleType.none;
      _dragStartGlobal = null;
      _rectStartNorm = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = _screenRect;
    final cropPixelW = (widget.normalizedRect.width * widget.rawImageWidth).round();
    final cropPixelH = (widget.normalizedRect.height * widget.rawImageHeight).round();

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        size: Size.infinite,
        painter: _CropPainter(
          screenCropRect: screen,
          imageBounds: Rect.fromLTWH(
            widget.imageOffset.dx,
            widget.imageOffset.dy,
            widget.imageDisplaySize.width,
            widget.imageDisplaySize.height,
          ),
        ),
        child: Stack(
          children: [
            // Dimension Pill Indicator
            Positioned(
              left: max(screen.left, 10),
              top: max(screen.top - 32, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.crop_rounded, color: AppColors.secondary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '$cropPixelW × $cropPixelH px',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final Rect screenCropRect;
  final Rect imageBounds;

  _CropPainter({
    required this.screenCropRect,
    required this.imageBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Darken the region outside the crop box
    final darkPaint = Paint()..color = Colors.black.withAlpha(150);

    final path = Path()
      ..addRect(imageBounds)
      ..addRect(screenCropRect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, darkPaint);

    // 2. Crop border outline
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(screenCropRect, borderPaint);

    // 3. Rule of Thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final thirdW = screenCropRect.width / 3;
    final thirdH = screenCropRect.height / 3;

    // Vertical grid lines
    canvas.drawLine(
      Offset(screenCropRect.left + thirdW, screenCropRect.top),
      Offset(screenCropRect.left + thirdW, screenCropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(screenCropRect.left + 2 * thirdW, screenCropRect.top),
      Offset(screenCropRect.left + 2 * thirdW, screenCropRect.bottom),
      gridPaint,
    );

    // Horizontal grid lines
    canvas.drawLine(
      Offset(screenCropRect.left, screenCropRect.top + thirdH),
      Offset(screenCropRect.right, screenCropRect.top + thirdH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(screenCropRect.left, screenCropRect.top + 2 * thirdH),
      Offset(screenCropRect.right, screenCropRect.top + 2 * thirdH),
      gridPaint,
    );

    // 4. Prominent Corner L-handles
    final cornerPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.square;

    const cornerLen = 18.0;

    // Top-Left
    canvas.drawLine(
      screenCropRect.topLeft,
      screenCropRect.topLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      screenCropRect.topLeft,
      screenCropRect.topLeft + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Top-Right
    canvas.drawLine(
      screenCropRect.topRight,
      screenCropRect.topRight + const Offset(-cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      screenCropRect.topRight,
      screenCropRect.topRight + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      screenCropRect.bottomLeft,
      screenCropRect.bottomLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      screenCropRect.bottomLeft,
      screenCropRect.bottomLeft + const Offset(0, -cornerLen),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      screenCropRect.bottomRight,
      screenCropRect.bottomRight + const Offset(-cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      screenCropRect.bottomRight,
      screenCropRect.bottomRight + const Offset(0, -cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
    return oldDelegate.screenCropRect != screenCropRect || oldDelegate.imageBounds != imageBounds;
  }
}
