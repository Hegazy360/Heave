import 'package:flutter/services.dart';
import 'package:heave/Map.dart';
import 'package:heave/Pictures.dart';
import 'package:flutter/material.dart';
import 'package:heave/Animals.dart';
import 'package:heave/News.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heave/blocs/animal_bloc/bloc.dart';
import 'package:heave/blocs/authentication_bloc/bloc.dart';
import 'package:heave/blocs/company_popup/companypopup_bloc.dart';
import 'package:heave/blocs/picture_bloc/picture_bloc.dart';
import 'package:heave/blocs/news_bloc/news_bloc.dart';
import 'package:heave/repositories/user_repository.dart';
import 'package:heave/blocs/simple_bloc_delegate.dart';
import 'package:heave/blocs/login_bloc/bloc.dart';
import 'package:heave/blocs/company_bloc/bloc.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      builder: (context) => AuthenticationBloc(userRepository: userRepository)
        ..dispatch(AppStarted()),
      child: MyApp(userRepository: userRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository _userRepository;

  MyApp({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'heave',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            builder: (BuildContext context) =>
                LoginBloc(userRepository: _userRepository),
          ),
          BlocProvider<CompanyBloc>(
            builder: (BuildContext context) => CompanyBloc(),
          ),
          BlocProvider<CompanypopupBloc>(
            builder: (BuildContext context) => CompanypopupBloc(),
          ),
          BlocProvider<PictureBloc>(
            builder: (BuildContext context) => PictureBloc(),
          ),
          BlocProvider<NewsBloc>(
            builder: (BuildContext context) => NewsBloc(),
          ),
          BlocProvider<AnimalBloc>(
            builder: (BuildContext context) => AnimalBloc(),
          ),
        ],
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocBuilder(
        bloc: BlocProvider.of<AuthenticationBloc>(context),
        builder: (BuildContext context, AuthenticationState state) {
          return Scaffold(
              bottomNavigationBar: FancyBottomNavigation(
                tabs: [
                  TabData(
                    iconData: Icons.map,
                    title: "Map",
                  ),
                  TabData(iconData: Icons.rss_feed, title: "News"),
                  TabData(
                    iconData: Icons.photo,
                    title: "Reminders",
                  ),
                  TabData(iconData: Icons.list, title: "Extinction"),
                ],
                onTabChangedListener: (position) {
                  setState(() {
                    currentPage = position;
                  });
                },
              ),
              body: Center(
                child: _getPage(
                    currentPage, state is Authenticated ? state.user : null),
              ));
        });
  }

  _getPage(int page, user) {
    switch (page) {
      case 0:
        return Map(user);
      case 1:
        return News(user);
      case 2:
        return Pictures(user);
      default:
        return Animals(user);
    }
  }
}
