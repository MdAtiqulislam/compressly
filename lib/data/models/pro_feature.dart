import 'package:flutter/material.dart';

class ProFeature {
  final String title;
  final String description;
  final IconData icon;

  const ProFeature({
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<ProFeature> proFeaturesList = [
    ProFeature(
      title: 'Exact Target-Size Compression',
      description: 'Compress photos down to any precise target (e.g. 50 KB, 100 KB, custom).',
      icon: Icons.compress_rounded,
    ),
    ProFeature(
      title: 'Unlimited Batch Processing',
      description: 'Process hundreds of images simultaneously without limits.',
      icon: Icons.photo_library_rounded,
    ),
    ProFeature(
      title: 'Full WebP & High-Res Support',
      description: 'Export to modern WebP format with next-gen image compression.',
      icon: Icons.hd_rounded,
    ),
    ProFeature(
      title: 'EXIF & GPS Metadata Cleaner',
      description: 'Strip sensitive location, camera and software data for 100% privacy.',
      icon: Icons.security_rounded,
    ),
    ProFeature(
      title: 'Ad-Free Experience',
      description: 'Fast, uninterrupted workflow with zero advertisements.',
      icon: Icons.block_rounded,
    ),
    ProFeature(
      title: 'Advanced Quality Controls',
      description: 'Custom dimensions, aspect locks, and fine-tuned lossy/lossless sliders.',
      icon: Icons.tune_rounded,
    ),
  ];
}
