import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    QuerySnapshot animalsSnapshot = await Firestore.instance
        .collection('animals')
        .orderBy("level", descending: true)
        .getDocuments();

    return animalsSnapshot.documents;
  }
}
