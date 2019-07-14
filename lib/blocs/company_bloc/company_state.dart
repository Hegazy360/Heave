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

  CompanyLoaded(this.companies) : super([companies]);

  @override
  String toString() {
    return 'CompanyLoaded { companies: $companies }';
  }
}

class InitialCompanyState extends CompanyState {}
