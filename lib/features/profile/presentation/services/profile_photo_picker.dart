import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Gallery-only photo selection for this UI milestone; no uploads occur.
abstract class ProfilePhotoPicker {
  Future<Uint8List?> pick();
}

class GalleryProfilePhotoPicker implements ProfilePhotoPicker {
  GalleryProfilePhotoPicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw StateError('Choose a photo smaller than 5 MB.');
    }
    return bytes;
  }
}
