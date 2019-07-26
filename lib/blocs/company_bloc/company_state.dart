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
  final List filteredCompanies;

  CompanyLoaded(this.companies, this.filteredCompanies) : super([companies, filteredCompanies]);

  @override
  String toString() {
    return 'CompanyLoaded { companies: $companies, filteredCompanies: $filteredCompanies }';
  }
}


class InitialCompanyState extends CompanyState {}
