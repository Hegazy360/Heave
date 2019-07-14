import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloc/bloc.dart';
import 'package:latlong/latlong.dart';
import './bloc.dart';

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
          yield CompanyLoaded(companies);
          return;
        }
      } catch (_) {
        yield CompanyError();
      }
    }
  }

  Future<List> _fetchCompanies() async {
    QuerySnapshot companiesSnapshot =
        await Firestore.instance.collection('companies').getDocuments();

    var companiesList = companiesSnapshot.documents;
    var companies = [];

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
