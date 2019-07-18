import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PictureState extends Equatable {
  PictureState([List props = const []]) : super(props);
}


class PicturesUninitialized extends PictureState {
  @override
  String toString() => 'PicturesUninitialized';
}

class PicturesError extends PictureState {
  @override
  String toString() => 'PicturesError';
}

class PicturesLoaded extends PictureState {
  final List pictures;

  PicturesLoaded(this.pictures) : super([pictures]);

  @override
  String toString() {
    return 'PicturesLoaded { pictures: $pictures }';
  }
}


class InitialPictureState extends PictureState {}
