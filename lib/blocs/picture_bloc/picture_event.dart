import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PictureEvent extends Equatable {
  PictureEvent([List props = const []]) : super(props);
}

class FetchPictures extends PictureEvent {
  @override
  String toString() => 'FetchPictures';
}