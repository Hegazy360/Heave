import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:latlong/latlong.dart';

@immutable
abstract class CompanyState extends Equatable {
  CompanyState([List props = const []]) : super(props);
}

class CompanyUninitialized extends CompanyState {
  @override
  String toString() => 'CompanyUninitialized';
}

class CompanyError extends CompanyState {
  @override
  String toString() => 'CompanyError';
}

class CompanyLoaded extends CompanyState {
  final List companies;
  final Map filteredCompanies;
  final int filter;
  final LatLng location;
  final bool showFilters;

  CompanyLoaded(this.companies, this.filteredCompanies, this.filter,
      this.location, this.showFilters)
      : super([companies, filteredCompanies, filter, location, showFilters]);

  CompanyLoaded copyWith(
      {List companies, Map filteredCompanies, int filter, LatLng location , bool showFilters}) {
    return CompanyLoaded(
      companies ?? this.companies,
      filteredCompanies ?? this.filteredCompanies,
      filter ?? this.filter,
      location ?? this.location,
      showFilters ?? this.showFilters,
    );
  }

  @override
  String toString() {
    var companiesLength = companies.length;
    var filteredCompaniesLength = filteredCompanies.length;
    return 'CompanyLoaded { companies: $companiesLength, filteredCompanies: $filteredCompaniesLength, filter: $filter, location: $location, showFilters: $showFilters }';
  }
}

class InitialCompanyState extends CompanyState {}
