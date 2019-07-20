import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  @override
  AnimalState get initialState => AnimalsUninitialized();

  @override
  Stream<AnimalState> mapEventToState(
    AnimalEvent event,
  ) async* {
    if (event is FetchAnimals) {
      try {
        if (currentState is AnimalsUninitialized) {
          final animals = await fetchAnimals();
          yield AnimalsLoaded(animals);
          return;
        }
      } catch (_) {
        yield AnimalsError();
      }
    }
  }

  Future<List> fetchAnimals() async {
    QuerySnapshot animalsSnapshotCache = await Firestore.instance
        .collection('animals')
        .orderBy("level", descending: true)
        .getDocuments(source: Source.cache);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var animalsList;
    String cacheDate = prefs.getString('cacheDate');
    String today = DateTime.now().toString();
    int lastCacheDaysDifference = DateTime.parse(today)
        .difference(DateTime.parse(cacheDate ?? today))
        .inDays;

    if (animalsSnapshotCache.documents.length > 0 &&
        lastCacheDaysDifference < 1) {
      print("CACHE FOUND");
      animalsList = animalsSnapshotCache.documents;
    } else {
      print("NO CACHE FOUND");
      print("Retrieving");
      QuerySnapshot companiesSnapshot = await Firestore.instance
          .collection('animals')
          .orderBy("level", descending: true)
          .getDocuments();
      animalsList = companiesSnapshot.documents;
      if (lastCacheDaysDifference > 1 ||cacheDate == null ) {
        print('updating cache date');
        String newCacheDate = DateTime.now().toString();
        await prefs.setString('cacheDate', newCacheDate.toString());
      }
    }

    return animalsList;
  }
}
