import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final File file;
  final String url;

  PickedImage({required this.file, required this.url});
}

class CrudService {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  // Cloudinary Setup
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'xnoysgec',
    'fluttertask8',
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  // Pick + upload an image for the "Add item" dialog
  Future<PickedImage?> pickImageForAddItem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final File file = File(pickedFile.path);

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    return PickedImage(file: file, url: response.secureUrl);
  }

  // CREATE
  Future<void> addItemWithImage(String name, int quantity, String? imageUrl) async {
    await items.add({
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
      'is_favorite': false,
      'created_at': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('created_at', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite(String id, bool currentValue) {
    return items.doc(id).update({
      'is_favorite': !currentValue,
    });
  }
}