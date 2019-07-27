import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CompanyEvent extends Equatable {
  CompanyEvent([List props = const []]) : super(props);
}

class FetchCompanies extends CompanyEvent {
  @override
  String toString() => 'FetchCompanies';
}

class PrepareCompaniesFilters extends CompanyEvent {
  @override
  String toString() => 'PrepareCompaniesFilters';
}

class UpdateFilter extends CompanyEvent {
  final filter;

  UpdateFilter({@required this.filter}) : super([filter]);
  
  @override
  String toString() => 'UpdateFilter';
}
