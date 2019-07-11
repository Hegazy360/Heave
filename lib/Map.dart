import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heave/CompanyPopup.dart';
import 'package:heave/MapInterface.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:heave/UserProfile.dart';
import 'package:flushbar/flushbar.dart';

class Map extends StatefulWidget {
  static const String route = 'map_controller_animated';

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<Map> with TickerProviderStateMixin {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  MapController mapController;
  List tappedPoints = [];
  AnimationController controller;
  Animation<Offset> offset;
  var activeCompany;
  FirebaseUser user;
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  Future _signIn(BuildContext context) async {
    var result = await facebookSignIn
        .logInWithReadPermissions(['email', 'public_profile']);
    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: myToken.token);
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((currentUser) {
        setState(() {
          user = currentUser;
        });
      });
      return user;
    } else {
      print(result.errorMessage);
    }
  }

  Future<Null> _signOut(BuildContext context) async {
    facebookSignIn.logOut();
    _fAuth.signOut();
    this.setState(() {
      user = null;
    });
    print('Signed out');
  }

  @override
  void initState() {
    super.initState();
    _getMarkers();
    mapController = MapController();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    var markers = tappedPoints.map((company) {
      return Marker(
          width: 60.0,
          height: 60.0,
          point: company['location'],
          builder: (ctx) => GestureDetector(
                onTap: () {
                  setState(() {
                    activeCompany = company;
                  });

                  switch (controller.status) {
                    // case AnimationStatus.completed:
                    // controller.reverse();
                    // break;
                    case AnimationStatus.dismissed:
                      controller.forward();
                      break;
                    default:
                  }
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(5),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: SpinKitPulse(
                                color: Colors.blueGrey,
                                size: 25.0,
                              ),
                            ),
                            FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: company['data']['logo_url'] ?? '',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          ],
                        ))),
              ));
    }).toList();

    return InnerDrawer(
        key: _innerDrawerKey,
        position: InnerDrawerPosition.start,
        onTapClose: true,
        swipe: false,
        animationType: InnerDrawerAnimation.quadratic,
        child: Material(
            child: SafeArea(
                child: Container(
          child: UserProfile(user, _signOut, _close),
        ))),
        scaffold: Stack(
          children: <Widget>[
            new MapInterface(
                mapController: mapController,
                controller: controller,
                markers: markers),
            activeCompany != null
                ? new CompanyPopup(offset: offset, activeCompany: activeCompany)
                : Container(),
            Positioned(
                bottom: 30,
                right: 20,
                child: FloatingActionButton(
                  heroTag: "add",
                  elevation: 3,
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    if (user == null) {
                      loginAlert(context, 'company').show();
                    } else {
                      companyFormAlert(context).show();
                    }
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.blueGrey,
                  ),
                )),
            Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton(
                  heroTag: "disconnect",
                  elevation: 3,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    user == null
                        ? loginAlert(context, 'profile').show()
                        : _open();
                  },
                  child: Icon(
                    Icons.person,
                    color: Colors.blueGrey,
                  ),
                )),
          ],
        ));
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
                      handleSignInEmail(email, password);
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
                  Navigator.pop(context);
                  _signIn(context).then((value) {
                    if (type == 'company')
                      companyFormAlert(context).show();
                    else
                      _open();
                  });
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
                      handleSignUp(email, password);
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
                  Navigator.pop(context);
                  _signIn(context).then((value) {
                    if (type == 'company')
                      companyFormAlert(context).show();
                    else
                      _open();
                  });
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
                        .document(user.uid)
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
                            .document(user.uid)
                            .setData({
                          'reports_count': 1,
                          'first_report_date': DateTime.now(),
                          'reports': FieldValue.arrayUnion([data]),
                        }, merge: true);
                      } else if (reportsCount < 5)
                        firestore
                            .collection("users")
                            .document(user.uid)
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
                              .document(user.uid)
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

  void handleSignInEmail(String email, String password) async {
    try {
      final FirebaseUser firebaseUser = await _fAuth.signInWithEmailAndPassword(
          email: email, password: password);

      setState(() {
        user = firebaseUser;
      });

      print('signInEmail succeeded: $user');
      Navigator.pop(context);
    } catch (e) {
      if (e.code == 'ERROR_USER_NOT_FOUND') {
        print('user not found');
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: "Sorry!",
          message: "No account has been found!",
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
      if (e.code == 'ERROR_WRONG_PASSWORD') {
        print('Wrong password');
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: "Oops..",
          message: "Wrong password",
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          boxShadows: [
            BoxShadow(
                color: Colors.red[800],
                offset: Offset(0.0, 2.0),
                blurRadius: 3.0)
          ],
          mainButton: FlatButton(
            onPressed: () {},
            child: Text(
              "Forgot Password",
              style: TextStyle(color: Colors.white),
            ),
          ),
          animationDuration: Duration(milliseconds: 500),
          icon: Icon(Icons.sentiment_dissatisfied, color: Colors.white),
          duration: Duration(seconds: 3),
        )..show(context);
      }
      if (e.code == 'ERROR_INVALID_EMAIL') {
        print('Something is wrong with the email!');
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: "Hmm..",
          message: "Something is wrong with the email",
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          boxShadows: [
            BoxShadow(
                color: Colors.red[800],
                offset: Offset(0.0, 2.0),
                blurRadius: 3.0)
          ],
          animationDuration: Duration(milliseconds: 500),
          icon: Icon(Icons.sentiment_very_dissatisfied, color: Colors.white),
          duration: Duration(seconds: 3),
        )..show(context);
      }
      print(e.code);
    }
  }

  void handleSignUp(email, password) async {
    try {
      final FirebaseUser firebaseUser = await _fAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      setState(() {
        user = firebaseUser;
      });

      print('signUp succeeded: $user');
      Navigator.pop(context);
    } catch (e) {
      if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        print('user not found');
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: "Oh!",
          message: "An account already exist with this email!",
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
              loginAlert(context, 'profile').show();
            },
            child: Text(
              "Login",
              style: TextStyle(color: Colors.white),
            ),
          ),
          animationDuration: Duration(milliseconds: 500),
          icon: Icon(Icons.sentiment_dissatisfied, color: Colors.white),
          duration: Duration(seconds: 3),
        )..show(context);
      }
      if (e.code == 'ERROR_WEAK_PASSWORD') {
        print('Weak password');
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: "Do you even lift password?",
          message: "Password is not strong enough!",
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          boxShadows: [
            BoxShadow(
                color: Colors.red[800],
                offset: Offset(0.0, 2.0),
                blurRadius: 3.0)
          ],
          animationDuration: Duration(milliseconds: 500),
          icon: Icon(Icons.sentiment_dissatisfied, color: Colors.white),
          duration: Duration(seconds: 3),
        )..show(context);
      }
      print(e.code);
    }
  }

  _getMarkers() async {
    QuerySnapshot companiesSnapshot =
        await Firestore.instance.collection('companies').getDocuments();
    var companiesList = companiesSnapshot.documents;

    companiesList.forEach((company) {
      company.data['branches'].forEach((geoPoint) {
        setState(() {
          tappedPoints.add({
            'data': company.data,
            'location': LatLng(
              geoPoint.latitude,
              geoPoint.longitude,
            ),
          });
        });
      });
    });
  }

  void _open() {
    _innerDrawerKey.currentState.open();
  }

  void _close() {
    _innerDrawerKey.currentState.close();
  }
}
