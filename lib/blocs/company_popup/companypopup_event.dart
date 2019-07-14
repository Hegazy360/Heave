import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CompanypopupEvent extends Equatable {
  CompanypopupEvent([List props = const []]) : super(props);
}

class SetActiveCompany extends CompanypopupEvent {
  final company;

  SetActiveCompany({@required this.company}) : super([company]);

  @override
  String toString() => 'setActiveCompany $company';
}
