import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/blocs/authentication_bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatefulWidget {
  final close;

  UserProfile(this.close);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<AuthenticationBloc>(context),
      builder: (BuildContext context, AuthenticationState state) {
        return Container(
          height: MediaQuery.of(context).size.height - 60,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => SpinKitPulse(
                            color: Colors.blueGrey,
                            size: 25.0,
                          ),
                          imageUrl: state is Authenticated
                              ? state.user['info'].photoUrl != null
                                  ? state.user['info'].photoUrl + "?height=500"
                                  : 'https://profilepicturesdp.com/wp-content/uploads/2018/06/default-profile-picture-funny-10.jpg'
                              : 'https://profilepicturesdp.com/wp-content/uploads/2018/06/default-profile-picture-funny-10.jpg',
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          fadeInDuration: Duration(seconds: 1),
                        )),
                  ),
                  Text(
                    state is Authenticated
                        ? state.user['info'].displayName ?? 'Batman'
                        : '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Level: ' +
                          (state is Authenticated && state.user['data'] != null
                              ? state.user['data']['level'].toString()
                              : ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      'Contact and report new companies to increase your level',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                    ),
                  ),
                  state is Authenticated &&
                          state.user['data']['reports'].length > 0
                      ? Container(
                          padding: EdgeInsets.only(top: 50, bottom: 40),
                          height: 350,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Text('Latest Activity'),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: state.user['data'] != null
                                      ? state.user['data']['reports'].length
                                      : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final reversedIndex =
                                        state.user['data']['reports'].length -
                                            index -
                                            1;
                                    return state.user['data']['reports']
                                                    [reversedIndex]
                                                ['company_name'] !=
                                            null
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Reported ' +
                                                      state.user['data']
                                                                  ['reports']
                                                              [reversedIndex]
                                                          ['company_name'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                Text(
                                                  state.user['data']['reports'][
                                                                      reversedIndex]
                                                                  [
                                                                  'approved'] !=
                                                              null &&
                                                          state.user['data'][
                                                                      'reports']
                                                                  [
                                                                  reversedIndex]
                                                              ['approved']
                                                      ? 'Approved'
                                                      : 'Pending',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: state.user['data'][
                                                                              'reports']
                                                                          [reversedIndex]
                                                                      [
                                                                      'approved'] !=
                                                                  null &&
                                                              state.user['data']
                                                                          ['reports']
                                                                      [reversedIndex]
                                                                  ['approved']
                                                          ? Colors.green
                                                          : Colors.orange),
                                                )
                                              ],
                                            ))
                                        : SizedBox();
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Column(
                            children: <Widget>[
                              Text('Latest Activity'),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 30,
                                ),
                              ),
                              Text("You have no activies yet"),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 7),
                                child: Text(
                                  "Start taking action to see your activities here",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ))
                ],
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: FlatButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    label: Text('Logout'),
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context).dispatch(
                        LoggedOut(),
                      );
                      widget.close();
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
