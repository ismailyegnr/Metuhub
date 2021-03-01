import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageActions {
  final picker = ImagePicker();
  Future<String> uploadImage(File image, toWhere) async {
    String imageUrl;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$toWhere/${Path.basename(image.path)}");

    UploadTask uploadTask = ref.putFile(image);

    uploadTask.then((res) async {
      imageUrl = await res.ref.getDownloadURL();
    });

    return imageUrl;
  }

  // ignore: missing_return
  Future<File> getImage() async {
    if (await Permission.mediaLibrary.request().isGranted) {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File cropped = await ImageCropper.cropImage(
          androidUiSettings: AndroidUiSettings(
              hideBottomControls: true, toolbarTitle: "photo".tr()),
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
          maxWidth: 800,
        );

        if (cropped != null) {
          var compressed = await FlutterImageCompress.compressAndGetFile(
            cropped.path,
            pickedFile.path,
            quality: 80,
          );

          print(cropped.lengthSync());
          print(compressed.lengthSync());

          return compressed;
        }
      }
    }
  }
}
