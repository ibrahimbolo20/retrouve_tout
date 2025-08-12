// lib/utils/mobile_image_picker.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<dynamic> pickImage([context, ImageSource? source]) async {
  if (source == null) {
    throw ArgumentError('ImageSource est requis sur mobile');
  }

  final picker = ImagePicker();
  final picked = await picker.pickImage(source: source, imageQuality: 50);
  if (picked != null) {
    return File(picked.path);
  }
  return null;
}
