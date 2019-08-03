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
import 'package:location/location.dart';

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
  MapController mapController = MapController();
  AnimationController controller;
  AnimationController tempController;
  Animation<Offset> offset;
  Animation<Offset> filtersOffset;
  Animation<double> filterButtonScale;
  Animation<double> filtersListOpacity;

  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  var location = new Location();

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

    tempController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(controller);
    filtersOffset =
        Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: tempController,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeOut,
        ),
      ),
    );
    filterButtonScale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: tempController,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
    filtersListOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: tempController,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  void _getUserLocation() async {
    try {
      await location.getLocation().then((value) {
        var currentLocation = LatLng(value.latitude, value.longitude);
        _companyBloc.dispatch(UpdateLocation(location: currentLocation));
        mapController.onReady.then((result) {
          mapController.move(currentLocation, 6);
        });
      });
    } catch (e) {
      var newYork = LatLng(40.7128, -74.0060);
      _companyBloc.dispatch(UpdateLocation(location: newYork));
      mapController.onReady.then((result) {
        mapController.move(newYork, 6);
      });
    }
  }

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
        scaffold:
            BlocListener<LoginBloc, LoginState>(listener: (context, state) {
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
              icon:
                  Icon(Icons.sentiment_very_satisfied, color: Colors.blueGrey),
              duration: Duration(seconds: 3),
            )..show(context);
            BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
            _open();
          }
        }, child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
          return BlocListener<CompanyBloc, CompanyState>(
            listener: (context, state) {
              if ((state as CompanyLoaded).location == null) {
                _getUserLocation();
              }
            },
            child: BlocBuilder<CompanyBloc, CompanyState>(
                builder: (context, state) {
              if (state is CompanyLoaded && state.location != null) {
                return Stack(
                  children: <Widget>[
                    MapInterface(
                        position: state.location,
                        mapController: mapController,
                        controller: controller,
                        markers: buildMapMarkers(state).toList()),
                    CompanyPopup(
                        offset: offset, markerLabelColors: markerLabelColors),
                    Positioned(
                        bottom: 40,
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
                              icon: Icon(Icons.my_location,
                                  color: Colors.blueGrey),
                              onTap: () {
                                _getUserLocation();
                                // mapController.move(state.location, 6.5);
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
                                        duration: Duration(milliseconds: 400),
                                        type: PageTransitionType.scale,
                                        child: MapIntro()));
                              },
                            ),
                          ],
                          elevation: 2,
                        )),
                    Positioned(
                      bottom: 50,
                      left: 20,
                      child: ScaleTransition(
                        scale: filterButtonScale,
                        child: Container(
                          child: FloatingActionButton(
                            heroTag: 'toggleFilters',
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.filter_list,
                              size: 30,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              tempController.forward();
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      child: FadeTransition(
                        opacity: filtersListOpacity,
                        child: SlideTransition(
                          position: filtersOffset,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildFilterButtons(state),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Center(
                      child: SpinKitPulse(
                        color: Colors.blueGrey,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        })));
  }

  List<Widget> buildFilterButtons(CompanyState state) {
    int filter = state is CompanyLoaded ? state.filter : -1;

    return <Widget>[
      RaisedButton(
        shape: Border(left: BorderSide(width: 5, color: markerLabelColors[5])),
        elevation: 1,
        color: filter == 5 ? Colors.black38 : Colors.black12,
        child: Container(
          width: 140,
          child: Text(
            'Animal Abuse',
            style: TextStyle(color: Colors.white),
          ),
        ),
        onPressed: () {
          _companyBloc.dispatch(UpdateFilter(filter: filter == 5 ? -1 : 5));
        },
      ),
      Row(
        children: <Widget>[
          RaisedButton(
            shape:
                Border(left: BorderSide(width: 5, color: markerLabelColors[4])),
            elevation: 1,
            color: filter == 4 ? Colors.black38 : Colors.black12,
            child: Container(
              width: 140,
              child: Text(
                'Plastic Pollution',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: () {
              _companyBloc.dispatch(UpdateFilter(filter: filter == 4 ? -1 : 4));
            },
          ),
          Container(
            width: 37,
            height: 37,
            margin: EdgeInsets.only(left: 7),
            child: FloatingActionButton(
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              backgroundColor: Colors.black38,
              onPressed: () {
                tempController.reverse();
              },
            ),
          ),
        ],
      ),
      RaisedButton(
        shape: Border(left: BorderSide(width: 5, color: markerLabelColors[3])),
        elevation: 1,
        color: filter == 3 ? Colors.black38 : Colors.black12,
        child: Container(
          width: 140,
          child: Text(
            'Working Conditions',
            style: TextStyle(color: Colors.white),
          ),
        ),
        onPressed: () {
          _companyBloc.dispatch(UpdateFilter(filter: filter == 3 ? -1 : 3));
        },
      ),

      // RaisedButton.icon(
      //   shape: Border(left: BorderSide(width: 5, color: markerLabelColors[2])),
      //   elevation: 1,
      //   color: filter == 2 ? Colors.black38 : Colors.black12,
      //   icon: Icon(Icons.filter_2, color: Colors.white),
      //   label: Container(
      //     width: 140,
      //     child: Text(
      //       'Level 2',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //   ),
      //   onPressed: () {
      //     _companyBloc.dispatch(UpdateFilter(filter: filter == 2 ? -1 : 2));
      //   },
      // ),
      // RaisedButton.icon(
      //   shape: Border(left: BorderSide(width: 5, color: markerLabelColors[1])),
      //   elevation: 1,
      //   color: filter == 1 ? Colors.black38 : Colors.black12,
      //   icon: Icon(Icons.filter_1, color: Colors.white),
      //   label: Container(
      //     width: 140,
      //     child: Text(
      //       'Level 1',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //   ),
      //   onPressed: () {
      //     _companyBloc.dispatch(UpdateFilter(filter: filter == 1 ? -1 : 1));
      //   },
      // ),
    ];
  }

  Iterable<Marker> buildMapMarkers(CompanyState state) {
    if (state is CompanyLoaded) {
      List filteredList = state.filteredCompanies[state.filter.toString()];
      return (state.filter == -1 ? state.companies : filteredList)
          .map((company) {
        return Marker(
            width: 60.0,
            height: 60.0,
            point: company['location'],
            builder: (ctx) => GestureDetector(
                  onTap: () {
                    _companyPopupBloc
                        .dispatch(SetActiveCompany(company: company));
                    switch (controller.status) {
                      case AnimationStatus.dismissed:
                        controller.forward();
                        break;
                      default:
                    }
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 5,
                                  color: markerLabelColors[company['data']
                                      ['level']]),
                            ),
                          ),
                          padding: EdgeInsets.all(9),
                          child: Stack(
                            children: <Widget>[
                              CachedNetworkImage(
                                placeholder: (context, url) => SpinKitPulse(
                                  color: Colors.blueGrey,
                                  size: 25.0,
                                ),
                                imageUrl: company['data']['logo_url'] ??
                                    'https://via.placeholder.com/140x100',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                fadeInDuration: Duration(seconds: 1),
                              )
                            ],
                          ))),
                ));
      });
    }
    return [];
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
                        .document(widget.user['info'].uid)
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
                        'sources': sources,
                        'approved': false
                      };
                      if (reportsCount == null) {
                        //first report
                        firestore
                            .collection("users")
                            .document(widget.user['info'].uid)
                            .setData({
                          'reports_count': 1,
                          'first_report_date': DateTime.now(),
                          'reports': FieldValue.arrayUnion([data]),
                        }, merge: true).then((value) {
                          BlocProvider.of<AuthenticationBloc>(context)
                              .dispatch(LoggedIn());
                        });
                      } else if (reportsCount < 5)
                        firestore
                            .collection("users")
                            .document(widget.user['info'].uid)
                            .setData({
                          'reports_count': reportsCount + 1,
                          'reports': FieldValue.arrayUnion([data]),
                        }, merge: true).then((value) {
                          BlocProvider.of<AuthenticationBloc>(context)
                              .dispatch(LoggedIn());
                        });
                      else {
                        var differenceInDays = DateTime.now()
                            .difference(firstReportDate.toDate())
                            .inDays;

                        if (differenceInDays >= 1 && reportsCount == 5) {
                          //reset
                          firestore
                              .collection("users")
                              .document(widget.user['info'].uid)
                              .setData({
                            'reports_count': 1,
                            'first_report_date': DateTime.now(),
                            'reports': FieldValue.arrayUnion([data]),
                          }, merge: true).then((value) {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .dispatch(LoggedIn());
                          });
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
