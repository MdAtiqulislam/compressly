import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(ImageSource source)? onSourceSelected;
  final VoidCallback? onFilesSelected;
  final bool allowMultiple;

  const ImagePickerBottomSheet({
    super.key,
    this.onSourceSelected,
    this.onFilesSelected,
    this.allowMultiple = false,
  });

  static Future<void> show({
    required Function(ImageSource source) onSourceSelected,
    VoidCallback? onFilesSelected,
    bool allowMultiple = false,
  }) {
    return Get.bottomSheet(
      ImagePickerBottomSheet(
        onSourceSelected: onSourceSelected,
        onFilesSelected: onFilesSelected,
        allowMultiple: allowMultiple,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            allowMultiple ? 'Select Multiple Images' : 'Select Image Source',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: AppColors.primary,
                onTap: () {
                  Get.back();
                  onSourceSelected?.call(ImageSource.gallery);
                },
              ),
              if (!allowMultiple)
                _PickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.secondary,
                  onTap: () {
                    Get.back();
                    onSourceSelected?.call(ImageSource.camera);
                  },
                ),
              _PickerOption(
                icon: Icons.folder_open_rounded,
                label: 'Files',
                color: AppColors.accent,
                onTap: () {
                  Get.back();
                  if (onFilesSelected != null) {
                    onFilesSelected!();
                  } else {
                    onSourceSelected?.call(ImageSource.gallery);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
