import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'CompanyPage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

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

  Future<FirebaseUser> _signIn(BuildContext context) async {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Sign in button clicked'),
    ));

    var result = await facebookSignIn
        .logInWithReadPermissions(['email', 'public_profile']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: myToken.token);

      user = await FirebaseAuth.instance.signInWithCredential(credential);
      print(user);
      ProviderDetails userInfo = new ProviderDetails(user.providerId, user.uid,
          user.displayName, user.photoUrl, user.email);

      List<ProviderDetails> providerData = new List<ProviderDetails>();
      providerData.add(userInfo);

      UserInfoDetails userInfoDetails = new UserInfoDetails(
          user.providerId,
          user.uid,
          user.displayName,
          user.photoUrl,
          user.email,
          user.isAnonymous,
          user.isEmailVerified,
          providerData);

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
                            )
                          ],
                        ))),
              ));
    }).toList();

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
              center: LatLng(51.5, -0.09),
              zoom: 3.0,
              minZoom: 3.0,
              maxZoom: 10.0,
              onTap: (position) {
                switch (controller.status) {
                  case AnimationStatus.completed:
                    controller.reverse();
                    break;
                  // case AnimationStatus.dismissed:
                  //   controller.forward();
                  //   break;
                  default:
                }
              },
              onPositionChanged: (position, value, value2) {
                switch (controller.status) {
                  case AnimationStatus.completed:
                    controller.reverse();
                    break;
                  // case AnimationStatus.dismissed:
                  //   controller.forward();
                  //   break;
                  default:
                }
              },
              plugins: [
                MarkerClusterPlugin(),
              ]),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/v4/"
                  "{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoiaGVnYXp5MzYwIiwiYSI6ImNqeGd0bWxldTA4a2gzb25ydzVycHU5cXUifQ.yB81RAqwBYSAXnLlImaCHg",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoiaGVnYXp5MzYwIiwiYSI6ImNqeGd0bWxldTA4a2gzb25ydzVycHU5cXUifQ.yB81RAqwBYSAXnLlImaCHg',
                'id': 'mapbox.streets',
              },
            ),
            MarkerClusterLayerOptions(
              maxClusterRadius: 50,
              height: 40,
              width: 40,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(150),
              ),
              markers: markers,
              polygonOptions: PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              builder: (context, markers) {
                return FloatingActionButton(
                  heroTag: UniqueKey().toString(),
                  child: Text(markers.length.toString()),
                  onPressed: null,
                );
              },
            ),
          ],
        ),
        activeCompany != null
            ? Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                    position: offset,
                    child: Container(
                      padding: EdgeInsets.only(top: 30, right: 10, left: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Hero(
                                    tag: 'company_name',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        activeCompany['data']['name'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )),
                              ),
                              Stack(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Hero(
                                        tag: 'company_image',
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Container(
                                                color: Colors.white,
                                                padding: EdgeInsets.all(5),
                                                child:
                                                    FadeInImage.memoryNetwork(
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: activeCompany['data']
                                                          ['logo_url'] ??
                                                      '',
                                                  fit: BoxFit.cover,
                                                  height: 100,
                                                  width: 100,
                                                )

                                                // Image.network(
                                                //   activeCompany['data']
                                                //           ['logo_url'] ??
                                                //       '',
                                                //   fit: BoxFit.cover,
                                                //   height: 100,
                                                //   width: 100,
                                                // ),
                                                )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            activeCompany['data']['accusations']
                                                    [0] ??
                                                '',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    width: 35,
                                    right: 8,
                                    child: FloatingActionButton(
                                      heroTag: UniqueKey().toString(),
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) {
                                            return CompanyPage(
                                              company: activeCompany,
                                            );
                                          }),
                                        );
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 30,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
              )
            : Container(),
        Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: "add",
              backgroundColor: Colors.white,
              onPressed: () async {
                FirebaseUser user = await _fAuth.currentUser();
                if (user == null) {
                  loginAlert(context).show();
                } else {
                  companyFormAlert(context).show();
                }
                // _signIn(context)
                //       .then((FirebaseUser user) => print(user));
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
              backgroundColor: Colors.redAccent,
              onPressed: () {
                _signOut(context);
              },
              child: Icon(
                Icons.close,
                color: Colors.blueGrey,
              ),
            )),
      ],
    );
  }

  Alert loginAlert(BuildContext context) {
    return Alert(
        context: context,
        title: "LOGIN",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Username',
              ),
            ),
            TextField(
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
                    Navigator.pop(context);
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
                  companyFormAlert(context).show();
                });
              },
            ),
          ],
        ),
        buttons: []);
  }

  Alert companyFormAlert(BuildContext context) {
    return Alert(
        context: context,
        title: "REPORT COMPANY",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Company name',
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'What do they do wrong ?',
              ),
            ),
          ],
        ),
        buttons: []);
  }
}

class UserInfoDetails {
  UserInfoDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
      this.email, this.isAnonymous, this.isEmailVerified, this.providerData);

  /// The provider identifier.
  final String providerId;

  /// The provider’s user ID for the user.
  final String uid;

  /// The name of the user.
  final String displayName;

  /// The URL of the user’s profile photo.
  final String photoUrl;

  /// The user’s email address.
  final String email;

  // Check anonymous
  final bool isAnonymous;

  //Check if email is verified
  final bool isEmailVerified;

  //Provider Data
  final List<ProviderDetails> providerData;
}

class ProviderDetails {
  final String providerId;

  final String uid;

  final String displayName;

  final String photoUrl;

  final String email;

  ProviderDetails(
      this.providerId, this.uid, this.displayName, this.photoUrl, this.email);
}
