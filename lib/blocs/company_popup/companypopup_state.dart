import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CompanypopupState extends Equatable {
  CompanypopupState([List props = const []]) : super(props);
}

class ActiveCompany extends CompanypopupState {
  final company;

  ActiveCompany(this.company) : super([company]);

  @override
  String toString() {
    return 'ActiveCompany { company: $company }';
  }
}

class InitialCompanypopupState extends CompanypopupState {}
