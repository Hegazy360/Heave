import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AnimalState extends Equatable {
  AnimalState([List props = const []]) : super(props);
}


class AnimalsUninitialized extends AnimalState {
  @override
  String toString() => 'AnimalsUninitialized';
}

class AnimalsError extends AnimalState {
  @override
  String toString() => 'AnimalsError';
}

class AnimalsLoaded extends AnimalState {
  final List animals;

  AnimalsLoaded(this.animals) : super([animals]);

  @override
  String toString() {
    return 'AnimalsLoaded { animals: $animals }';
  }
}


class InitialAnimalState extends AnimalState {}
