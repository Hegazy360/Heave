import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class CompanypopupBloc extends Bloc<CompanypopupEvent, CompanypopupState> {
  @override
  CompanypopupState get initialState => InitialCompanypopupState();

  @override
  Stream<CompanypopupState> mapEventToState(
    CompanypopupEvent event,
  ) async* {
    if(event is SetActiveCompany){
      yield ActiveCompany(event.company);  
    }
  }
}
