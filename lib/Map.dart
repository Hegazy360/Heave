import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heave/CompanyPopup.dart';
import 'package:heave/MapInterface.dart';
import 'package:heave/blocs/company_bloc/bloc.dart';
import 'package:heave/blocs/company_popup/bloc.dart';
import 'package:heave/intro/Map.dart';
import 'package:latlong/latlong.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:heave/UserProfile.dart';
import 'package:flushbar/flushbar.dart';
import 'package:heave/blocs/login_bloc/bloc.dart';
import 'package:heave/blocs/authentication_bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:floating_action_row/floating_action_row.dart';
import 'package:page_transition/page_transition.dart';

class Map extends StatefulWidget {
  static const String route = 'map_controller_animated';
  final user;

  Map(this.user);

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<Map> with TickerProviderStateMixin {
  MapController mapController;
  AnimationController controller;
  Animation<Offset> offset;
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  var userPosition = LatLng(45.7575136, 4.8667044);

  LoginBloc _loginBloc;
  CompanyBloc _companyBloc;
  CompanypopupBloc _companyPopupBloc;
  List markerLabelColors = [
    Colors.white,
    Colors.yellow,
    Colors.orange,
    Colors.red[400],
    Colors.red[900],
    Colors.black
  ];

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _companyBloc = BlocProvider.of<CompanyBloc>(context);
    _companyPopupBloc = BlocProvider.of<CompanypopupBloc>(context);
    _companyBloc.dispatch(FetchCompanies());

    _getUserLocation();

    mapController = MapController();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(controller);
  }

  void _getUserLocation() async {}

  @override
  Widget build(BuildContext context) {
    return InnerDrawer(
        key: _innerDrawerKey,
        position: InnerDrawerPosition.start,
        onTapClose: true,
        swipe: false,
        animationType: InnerDrawerAnimation.quadratic,
        child: Material(
            child: SafeArea(
                child: Container(
          child: UserProfile(_close),
        ))),
        scaffold: BlocListener(
            bloc: _loginBloc,
            listener: (BuildContext context, LoginState state) {
              if (state.isFailure) {
                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  title: "Sorry!",
                  message: "Login failed!",
                  reverseAnimationCurve: Curves.decelerate,
                  forwardAnimationCurve: Curves.elasticOut,
                  boxShadows: [
                    BoxShadow(
                        color: Colors.red[800],
                        offset: Offset(0.0, 2.0),
                        blurRadius: 3.0)
                  ],
                  mainButton: FlatButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      signUpAlert(context, 'profile').show();
                    },
                    child: Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  animationDuration: Duration(milliseconds: 500),
                  icon: Icon(Icons.sentiment_dissatisfied, color: Colors.white),
                  duration: Duration(seconds: 3),
                )..show(context);
              }
              if (state.isSubmitting) {
                Flushbar(
                  backgroundColor: Colors.white,
                  flushbarPosition: FlushbarPosition.TOP,
                  titleText: Text(
                    'One second',
                    style: TextStyle(
                        color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  ),
                  messageText: Text(
                    'Checking credentials...',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  showProgressIndicator: true,
                  reverseAnimationCurve: Curves.decelerate,
                  forwardAnimationCurve: Curves.elasticOut,
                  boxShadows: [
                    BoxShadow(
                        color: Colors.yellow[800],
                        offset: Offset(0.0, 2.0),
                        blurRadius: 3.0)
                  ],
                  animationDuration: Duration(milliseconds: 500),
                  icon: Icon(Icons.sentiment_neutral, color: Colors.grey),
                  duration: Duration(seconds: 3),
                )..show(context);
              }
              if (state.isSuccess) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Flushbar(
                  backgroundColor: Colors.white,
                  flushbarPosition: FlushbarPosition.TOP,
                  titleText: Text(
                    'Awesome!',
                    style: TextStyle(
                        color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  ),
                  messageText: Text(
                    'Beautiful picture you got there',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  reverseAnimationCurve: Curves.decelerate,
                  forwardAnimationCurve: Curves.elasticOut,
                  boxShadows: [
                    BoxShadow(
                        color: Colors.blue[800],
                        offset: Offset(0.0, 2.0),
                        blurRadius: 3.0)
                  ],
                  animationDuration: Duration(milliseconds: 500),
                  icon: Icon(Icons.sentiment_very_satisfied,
                      color: Colors.blueGrey),
                  duration: Duration(seconds: 3),
                )..show(context);
                BlocProvider.of<AuthenticationBloc>(context)
                    .dispatch(LoggedIn());
                _open();
              }
            },
            child: BlocBuilder(
                bloc: _loginBloc,
                builder: (BuildContext context, LoginState state) {
                  return Stack(
                    children: <Widget>[
                      BlocBuilder(
                          bloc: _companyBloc,
                          builder: (BuildContext context, CompanyState state) {
                            return MapInterface(
                                position: userPosition,
                                mapController: mapController,
                                controller: controller,
                                markers: state is CompanyLoaded
                                    ? (state.filteredCompanies.length > 1
                                            ? state.filteredCompanies
                                            : state.companies)
                                        .map((company) {
                                        return Marker(
                                            width: 60.0,
                                            height: 60.0,
                                            point: company['location'],
                                            builder: (ctx) => GestureDetector(
                                                  onTap: () {
                                                    _companyPopupBloc.dispatch(
                                                        SetActiveCompany(
                                                            company: company));
                                                    switch (controller.status) {
                                                      case AnimationStatus
                                                          .dismissed:
                                                        controller.forward();
                                                        break;
                                                      default:
                                                    }
                                                  },
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border(
                                                              bottom: BorderSide(
                                                                  width: 5,
                                                                  color: markerLabelColors[
                                                                      company['data']
                                                                          [
                                                                          'level']]),
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(9),
                                                          child: Stack(
                                                            children: <Widget>[
                                                              CachedNetworkImage(
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitPulse(
                                                                  color: Colors
                                                                      .blueGrey,
                                                                  size: 25.0,
                                                                ),
                                                                imageUrl: company[
                                                                            'data']
                                                                        [
                                                                        'logo_url'] ??
                                                                    'https://via.placeholder.com/140x100',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: 100,
                                                                height: 100,
                                                                fadeInDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                              )
                                                            ],
                                                          ))),
                                                ));
                                      }).toList()
                                    : []);
                          }),
                      CompanyPopup(
                          offset: offset, markerLabelColors: markerLabelColors),
                      Positioned(
                          bottom: 30,
                          right: 20,
                          child: FloatingActionRow(
                            axis: Axis.vertical,
                            children: [
                              FloatingActionRowButton(
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.blueGrey,
                                ),
                                onTap: () {
                                  widget.user != null
                                      ? _open()
                                      : loginAlert(context, 'profile').show();
                                },
                              ),
                              FloatingActionRowDivider(color: Colors.blueGrey),
                              FloatingActionRowButton(
                                icon: Icon(Icons.add, color: Colors.blueGrey),
                                onTap: () {
                                  if (widget.user != null) {
                                    companyFormAlert(context).show();
                                  } else {
                                    loginAlert(context, 'company').show();
                                  }
                                },
                              ),
                              FloatingActionRowDivider(color: Colors.blueGrey),
                              FloatingActionRowButton(
                                icon: Icon(Icons.help_outline,
                                    color: Colors.blueGrey),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          duration: Duration(milliseconds: 500),
                                          type: PageTransitionType.fade,
                                          child: MapIntro()));
                                },
                              ),
                            ],
                            color: Colors.white,
                            elevation: 4,
                          )),
                      Positioned(
                        bottom: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RaisedButton.icon(
                              shape: Border(
                                  left: BorderSide(
                                      width: 5, color: markerLabelColors[5])),
                              elevation: 1,
                              color: Colors.transparent,
                              icon: Icon(Icons.filter_5, color: Colors.white),
                              label: Text(
                                'Animal Abuse',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _companyBloc
                                    .dispatch(SetCompaniesFilter(filter: 5));
                              },
                            ),
                            RaisedButton.icon(
                              shape: Border(
                                  left: BorderSide(
                                      width: 5, color: markerLabelColors[4])),
                              elevation: 1,
                              color: Colors.transparent,
                              icon: Icon(Icons.filter_4, color: Colors.white),
                              label: Text(
                                'Plastic Pollution',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _companyBloc
                                    .dispatch(SetCompaniesFilter(filter: 4));
                              },
                            ),
                            RaisedButton.icon(
                              shape: Border(
                                  left: BorderSide(
                                      width: 5, color: markerLabelColors[3])),
                              elevation: 1,
                              color: Colors.transparent,
                              icon: Icon(Icons.filter_3, color: Colors.white),
                              label: Text(
                                'Waste',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _companyBloc
                                    .dispatch(SetCompaniesFilter(filter: 3));
                              },
                            ),
                            RaisedButton.icon(
                              shape: Border(
                                  left: BorderSide(
                                      width: 5, color: markerLabelColors[2])),
                              elevation: 1,
                              color: Colors.transparent,
                              icon: Icon(Icons.filter_2, color: Colors.white),
                              label: Text(
                                'Abuse - small',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _companyBloc
                                    .dispatch(SetCompaniesFilter(filter: 2));
                              },
                            ),
                            RaisedButton.icon(
                              shape: Border(
                                  left: BorderSide(
                                      width: 5, color: markerLabelColors[1])),
                              elevation: 1,
                              color: Colors.transparent,
                              icon: Icon(Icons.filter_1, color: Colors.white),
                              label: Text(
                                'Plastic - small',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _companyBloc
                                    .dispatch(SetCompaniesFilter(filter: 1));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                })));
  }

  Alert loginAlert(BuildContext context, type) {
    String email;
    String password;

    return Alert(
        context: context,
        title: "Login",
        style: AlertStyle(
          animationType: AnimationType.fromBottom,
          animationDuration: Duration(milliseconds: 300),
          titleStyle: TextStyle(fontSize: 16),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Email',
                ),
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SignInButtonBuilder(
                    text: 'Login',
                    icon: Icons.email,
                    onPressed: () {
                      _loginBloc.dispatch(
                        LoginWithCredentialsPressed(
                          email: email,
                          password: password,
                        ),
                      );
                      // handleSignInEmail(email, password);
                    },
                    backgroundColor: Colors.blueGrey,
                  )),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "OR",
                  textAlign: TextAlign.center,
                ),
              ),
              SignInButton(
                Buttons.Facebook,
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context).dispatch(
                    LoginWithFacebookPressed(),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "What?! You don't have an account?",
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              FlatButton.icon(
                icon: Icon(
                  Icons.add_circle_outline,
                ),
                label: Text(
                  'Create Account',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  signUpAlert(context, 'profile').show();
                },
              )
            ],
          ),
        ),
        buttons: []);
  }

  Alert signUpAlert(context, type) {
    String email;
    String password;

    return Alert(
        context: context,
        title: "Sign Up",
        style: AlertStyle(
          animationType: AnimationType.fromBottom,
          animationDuration: Duration(milliseconds: 300),
          titleStyle: TextStyle(fontSize: 16),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Email',
                ),
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SignInButtonBuilder(
                    text: 'Create account',
                    icon: Icons.email,
                    onPressed: () {
                      _loginBloc.dispatch(
                        Submitted(
                          email: email,
                          password: password,
                        ),
                      );
                    },
                    backgroundColor: Colors.blueGrey,
                  )),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "OR",
                  textAlign: TextAlign.center,
                ),
              ),
              SignInButton(
                Buttons.Facebook,
                text: 'Sign up with Facebook',
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context).dispatch(
                    LoginWithFacebookPressed(),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              FlatButton.icon(
                icon: Icon(
                  Icons.add_circle_outline,
                ),
                label: Text(
                  'Login',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  loginAlert(context, 'profile').show();
                },
              )
            ],
          ),
        ),
        buttons: []);
  }

  Alert companyFormAlert(BuildContext context) {
    String companyName;
    String accusations;
    String sources;

    return Alert(
        context: context,
        title: "REPORT COMPANY",
        style: AlertStyle(
          animationType: AnimationType.fromRight,
          animationDuration: Duration(milliseconds: 300),
          titleStyle: TextStyle(fontSize: 16),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  companyName = value;
                },
                decoration: InputDecoration(
                    icon: Icon(Icons.account_circle),
                    labelText: 'Company name*',
                    errorText: companyName != null && companyName.isEmpty
                        ? 'This field is required!'
                        : null),
              ),
              TextField(
                onChanged: (value) {
                  accusations = value;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'What do they do wrong ?',
                ),
              ),
              TextField(
                onChanged: (value) {
                  sources = value;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Sources (Articles, Videos, ...)',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Requests will be studied and should be approved before being visible.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FlatButton.icon(
                  color: Colors.blueGrey,
                  textColor: Colors.white,
                  label: Text('Send request'),
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Firestore firestore = Firestore.instance;
                    firestore
                        .collection("users")
                        .document(widget.user.uid)
                        .get()
                        .then((ds) {
                      print('itsa mario');
                      print(ds.data);
                      int reportsCount =
                          ds.data == null ? null : ds.data['reports_count'];
                      Timestamp firstReportDate =
                          ds.data == null ? null : ds.data['first_report_date'];
                      var data = {
                        'company_name': companyName,
                        'accusations': accusations,
                        'sources': sources
                      };
                      if (reportsCount == null) {
                        //first report
                        firestore
                            .collection("users")
                            .document(widget.user.uid)
                            .setData({
                          'reports_count': 1,
                          'first_report_date': DateTime.now(),
                          'reports': FieldValue.arrayUnion([data]),
                        }, merge: true);
                      } else if (reportsCount < 5)
                        firestore
                            .collection("users")
                            .document(widget.user.uid)
                            .setData({
                          'reports_count': reportsCount + 1,
                          'reports': FieldValue.arrayUnion([data]),
                        }, merge: true);
                      else {
                        var differenceInDays = DateTime.now()
                            .difference(firstReportDate.toDate())
                            .inDays;

                        if (differenceInDays >= 1 && reportsCount == 5) {
                          //reset
                          firestore
                              .collection("users")
                              .document(widget.user.uid)
                              .setData({
                            'reports_count': 1,
                            'first_report_date': DateTime.now(),
                            'reports': FieldValue.arrayUnion([data]),
                          }, merge: true);
                        } else {
                          //display limit message
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            title: "Sorry!",
                            message: "You've reached your daily limit.",
                            animationDuration: Duration(milliseconds: 500),
                            icon: Icon(Icons.sentiment_dissatisfied,
                                color: Colors.white),
                            duration: Duration(seconds: 3),
                          )..show(context);
                        }
                      }
                    });
                  },
                ),
              )
            ],
          ),
        ),
        buttons: []);
  }

  void _open() {
    _innerDrawerKey.currentState.open();
  }

  void _close() {
    _innerDrawerKey.currentState.close();
  }
}
