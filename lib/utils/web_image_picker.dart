// lib/utils/web_image_picker.dart
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<dynamic> pickImage([BuildContext? context, ImageSource? source]) async {
  if (context == null) {
    throw ArgumentError('Le contexte est requis sur le web');
  }

  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.attributes['capture'] = 'environment';
  input.click();

  await input.onChange.first;

  if (input.files!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aucune image sélectionnée')),
    );
    return null;
  }

  final file = input.files!.first;
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  return {
    'fileName': file.name,
    'bytes': reader.result as Uint8List,
  };
}
