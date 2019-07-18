import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AnimalEvent extends Equatable {
  AnimalEvent([List props = const []]) : super(props);
}

class FetchAnimals extends AnimalEvent {
  @override
  String toString() => 'FetchAnimals';
}