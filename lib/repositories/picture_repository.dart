import 'package:cloud_firestore/cloud_firestore.dart';

class PictureRepository {
  Future<List<DocumentSnapshot>> fetchPictures() async {
    QuerySnapshot animalsSnapshot = await Firestore.instance
        .collection('animals')
        .orderBy("level", descending: true)
        .getDocuments();

    return animalsSnapshot.documents;
  }
}
