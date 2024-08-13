import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  return await picker.pickImage(source: source);
}

File getImageFile(XFile file) {
  return File(file.path);
}
