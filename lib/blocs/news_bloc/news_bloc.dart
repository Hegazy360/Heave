import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  @override
  NewsState get initialState => NewsUninitialized();

  @override
  Stream<NewsState> mapEventToState(
    NewsEvent event,
  ) async* {
    if (event is FetchNews) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (currentState is NewsUninitialized) {
          final climateNews = await fetchClimateNews(prefs);
          final oceanNews = await fetchOceanNews(prefs);
          yield NewsLoaded(climateNews, oceanNews);
          return;
        }
      } catch (_) {
        yield NewsError();
      }
    }
  }

  Future<List> fetchClimateNews(SharedPreferences prefs) async {
    String climateNewsCache = prefs.getString('climateNews');
    String cacheDate = prefs.getString('cacheDate');
    List news;
    String today = DateTime.now().toString();
    int lastCacheDaysDifference = DateTime.parse(today)
        .difference(DateTime.parse(cacheDate ?? today))
        .inDays;

    if (climateNewsCache != null && lastCacheDaysDifference < 1) {
      print("CACHE FOUND");
      news = json.decode(climateNewsCache)['articles'] as List;
      news.sort((a, b) => b['publishedAt'].compareTo(a['publishedAt']));
    } else {
      print("NO CACHE FOUND");
      final climateNews = await http.get(
          "https://newsapi.org/v2/everything?q=%22Global%20warming%22%20AND%20%22Climate%20Change%22&language=en&sortBy=popularity&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
      news = json.decode(climateNews.body)['articles'] as List;
      news.sort((a, b) => b['publishedAt'].compareTo(a['publishedAt']));
      await prefs.setString('climateNews', climateNews.body);
      if (lastCacheDaysDifference > 1 || cacheDate == null) {
        String newCacheDate = DateTime.now().toString();
        await prefs.setString('cacheDate', newCacheDate.toString());
      }
    }
    return news;
  }

  Future<List> fetchOceanNews(SharedPreferences prefs) async {
    String oceanNewsCache = prefs.getString('oceanNews');
    String cacheDate = prefs.getString('cacheDate');
    List news;
    String today = DateTime.now().toString();
    int lastCacheDaysDifference = DateTime.parse(today)
        .difference(DateTime.parse(cacheDate ?? today))
        .inDays;

    if (oceanNewsCache != null && lastCacheDaysDifference < 1) {
      print("CACHE FOUND");
      news = json.decode(oceanNewsCache)['articles'] as List;
      news.sort((a, b) => b['publishedAt'].compareTo(a['publishedAt']));
    } else {
      print("NO CACHE FOUND");
      final oceanNews = await http.get(
          "https://newsapi.org/v2/everything?q=%22Plastic%20Pollution%22&language=en&sortBy=popularity&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
      news = json.decode(oceanNews.body)['articles'] as List;
      news.sort((a, b) => b['publishedAt'].compareTo(a['publishedAt']));
      await prefs.setString('oceanNews', oceanNews.body);
      if (lastCacheDaysDifference > 1 || cacheDate == null) {
        String newCacheDate = DateTime.now().toString();
        await prefs.setString('cacheDate', newCacheDate.toString());
      }
    }
    return news;
  }
}
