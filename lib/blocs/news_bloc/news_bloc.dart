import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  @override
  NewsState get initialState => NewsUninitialized();

  @override
  Stream<NewsState> mapEventToState(
    NewsEvent event,
  ) async* {
    if (event is FetchNews) {
      try {
        if (currentState is NewsUninitialized) {
          final climateNews = await fetchClimateNews();
          final oceanNews = await fetchOceanNews();
          yield NewsLoaded(climateNews, oceanNews);
          return;
        }
      } catch (_) {
        yield NewsError();
      }
    }
  }

  Future<List> fetchClimateNews() async {
    final climateNews = await http.get(
        "https://newsapi.org/v2/everything?q=global+warming&sortBy=publishedAt&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");

    return json.decode(climateNews.body)['articles'] as List;
  }

  Future<List> fetchOceanNews() async {
    final oceanNews = await http.get(
        "https://newsapi.org/v2/everything?q=ocean+pollution+plastic&sortBy=publishedAt&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");

    return json.decode(oceanNews.body)['articles'] as List;
  }
}
