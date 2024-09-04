import 'dart:async';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage(ImageSource source) async {
  final completer = Completer<XFile>();
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();
  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files!.isNotEmpty) {
      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        completer.complete(XFile(reader.result as String));
      });
    }
  });
  return completer.future;
}

XFile getImageFile(XFile file) {
  return file; // For web, we return the XFile directly
}
