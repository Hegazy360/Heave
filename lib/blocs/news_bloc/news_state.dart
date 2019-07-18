import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NewsState extends Equatable {
  NewsState([List props = const []]) : super(props);
}

class NewsUninitialized extends NewsState {
  @override
  String toString() => 'NewsUninitialized';
}

class NewsError extends NewsState {
  @override
  String toString() => 'NewsError';
}

class NewsLoaded extends NewsState {
  final List climateNewsList;
  final List oceanNewsList;

  NewsLoaded(this.climateNewsList, this.oceanNewsList)
      : super([climateNewsList, oceanNewsList]);

  @override
  String toString() {
    return 'NewsLoaded { News: $climateNewsList $oceanNewsList }';
  }
}

class InitialNewstate extends NewsState {}
