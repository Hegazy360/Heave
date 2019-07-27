import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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

  CompanyLoaded(this.companies, this.filteredCompanies, this.filter)
      : super([companies, filteredCompanies, filter]);

  CompanyLoaded copyWith({List companies, Map filteredCompanies, int filter}) {
    return CompanyLoaded(companies ?? this.companies,
        filteredCompanies ?? this.filteredCompanies, filter ?? this.filter);
  }

  @override
  String toString() {
    return 'CompanyLoaded { companies: $companies, filteredCompanies: $filteredCompanies, filter: $filter }';
  }
}

class InitialCompanyState extends CompanyState {}
