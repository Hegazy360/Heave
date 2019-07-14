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
        // if (state is Uninitialized) {
        //   return SplashScreen();
        // }
        // if (state is Authenticated) {
        //   return HomeScreen(name: state.displayName);
        // }
        return Container(
          child: Column(
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
                          ? state.user.photoUrl != null
                              ? state.user.photoUrl + "?height=500"
                              : 'https://profilepicturesdp.com/wp-content/uploads/2018/06/default-profile-picture-funny-10.jpg'
                          : 'https://via.placeholder.com/140x100',
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                      fadeInDuration: Duration(seconds: 1),
                    )),
              ),
              Text(
                state is Authenticated
                    ? state.user.displayName ?? 'Batman'
                    : '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => SpinKitPulse(
                            color: Colors.blueGrey,
                            size: 25.0,
                          ),
                      imageUrl:
                          'https://previews.123rf.com/images/coolvectorstock/coolvectorstock1808/coolvectorstock180803940/106920397-achievement-icon-vector-isolated-on-white-background-for-your-web-and-mobile-app-design-achievement-.jpg' ??
                              'https://via.placeholder.com/140x100',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    )),
              ),
              Text(
                'Master',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
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
            ],
          ),
        );
      },
    );
  }
}
