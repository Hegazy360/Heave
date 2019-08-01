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
          yield CompanyLoaded(companies, {}, -1, null, false);
          dispatch(PrepareCompaniesFilters());
          return;
        }
      } catch (_) {
        yield CompanyError();
      }
    }
    if (event is PrepareCompaniesFilters) {
      try {
        if (currentState is CompanyLoaded) {
          var companies = (currentState as CompanyLoaded).companies;
          var filteredCompanies = {};
          for (var i = 1; i < 6; i++) {
            filteredCompanies.addAll({
              i.toString(): companies
                  .where((company) => company['data']['level'] == i)
                  .toList()
            });
          }
          yield (currentState as CompanyLoaded)
              .copyWith(filteredCompanies: filteredCompanies);
          return;
        }
      } catch (_) {
        yield CompanyError();
      }
    }
    if (event is UpdateFilter) {
      if (currentState is CompanyLoaded) {
        yield (currentState as CompanyLoaded).copyWith(filter: event.filter);
      }
      return;
    }
    if (event is UpdateLocation) {
      if (currentState is CompanyLoaded) {
        yield (currentState as CompanyLoaded)
            .copyWith(location: event.location);
      }
      return;
    }
    if (event is ToggleFilters) {
      if (currentState is CompanyLoaded) {
        yield (currentState as CompanyLoaded)
            .copyWith(showFilters: !(currentState as CompanyLoaded).showFilters);
      }
      return;
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
