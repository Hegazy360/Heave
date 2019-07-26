import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloc/bloc.dart';
import 'package:latlong/latlong.dart';
import './bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  @override
  CompanyState get initialState => CompanyUninitialized();

  @override
  Stream<CompanyState> mapEventToState(
    CompanyEvent event,
  ) async* {
    if (event is FetchCompanies) {
      try {
        if (currentState is CompanyUninitialized) {
          final companies = await _fetchCompanies();
          yield CompanyLoaded(companies, []);
          return;
        }
      } catch (_) {
        yield CompanyError();
      }
    }
    if (event is SetCompaniesFilter) {
      try {
        if (currentState is CompanyLoaded) {
          var companies = (currentState as CompanyLoaded).companies;
          var filteredCompanies = companies.where((company) => company['data']['level'] == event.filter).toList();

          yield CompanyLoaded((currentState as CompanyLoaded).companies, filteredCompanies);
          return;
        }
      } catch (_) {
        yield CompanyError();
      }
    }
  }

  Future<List> _fetchCompanies() async {
    QuerySnapshot companiesSnapshotCache = await Firestore.instance
        .collection('companies')
        .getDocuments(source: Source.cache);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var companiesList;
    var companies = [];

    String cacheDate = prefs.getString('cacheDate');
    String today = DateTime.now().toString();
    int lastCacheDaysDifference = DateTime.parse(today)
        .difference(DateTime.parse(cacheDate ?? today))
        .inDays;

    if (companiesSnapshotCache.documents.length > 0 &&
        lastCacheDaysDifference < 1) {
      print(
          "CACHE FOUND AND IS $lastCacheDaysDifference days old, fresh, can be used");
      companiesList = companiesSnapshotCache.documents;
    } else {
      print("NO CACHE FOUND");
      print("Retrieving");
      QuerySnapshot companiesSnapshot =
          await Firestore.instance.collection('companies').getDocuments();
      companiesList = companiesSnapshot.documents;
      if (lastCacheDaysDifference > 1 || cacheDate == null) {
        print('updating cache date');
        String newCacheDate = DateTime.now().toString();
        await prefs.setString('cacheDate', newCacheDate.toString());
      }
    }

    companiesList.forEach((company) {
      company.data['branches'].forEach((geoPoint) {
        companies.add({
          'data': company.data,
          'location': LatLng(
            geoPoint.latitude,
            geoPoint.longitude,
          ),
        });
      });
    });

    return companies;
  }
}
