import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var picturesList;
    String cacheDate = prefs.getString('cacheDate');
    String today = DateTime.now().toString();
    int lastCacheDaysDifference = DateTime.parse(today)
        .difference(DateTime.parse(cacheDate ?? today))
        .inDays;

    if (picturesSnapshotCache.documents.length > 0 &&
        lastCacheDaysDifference < 1) {
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
      if (lastCacheDaysDifference > 1 ||cacheDate == null ) {
        print('updating cache date');
        String newCacheDate = DateTime.now().toString();
        await prefs.setString('cacheDate', newCacheDate.toString());
      }
    }

    return picturesList;
  }
}
