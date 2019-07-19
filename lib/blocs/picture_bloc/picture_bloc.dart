import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  @override
  PictureState get initialState => PicturesUninitialized();

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is FetchPictures) {
      try {
        if (currentState is PicturesUninitialized) {
          final pictures = await fetchPictures();
          yield PicturesLoaded(pictures);
          return;
        }
      } catch (_) {
        yield PicturesError();
      }
    }
  }

  Future<List> fetchPictures() async {
    QuerySnapshot picturesSnapshotCache = await Firestore.instance
        .collection('pictures')
        .orderBy("date", descending: true)
        .getDocuments(source: Source.cache);

    var picturesList;

    if (picturesSnapshotCache.documents.length > 0) {
      print("CACHE FOUND");
      picturesList = picturesSnapshotCache.documents;
    } else {
      print("NO CACHE FOUND");
      print("Retrieving");
      QuerySnapshot companiesSnapshot = await Firestore.instance
        .collection('pictures')
        .orderBy("date", descending: true)
        .getDocuments();
      picturesList = companiesSnapshot.documents;
    }

    return picturesList;
  }
}
