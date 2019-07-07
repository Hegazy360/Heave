import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class UserProfile extends StatefulWidget {
  final user;
  final signOut;
  final close;

  UserProfile(this.user, this.signOut, this.close);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: widget.user != null
                      ? widget.user.photoUrl != null
                          ? widget.user.photoUrl + "?height=500"
                          : 'https://profilepicturesdp.com/wp-content/uploads/2018/06/default-profile-picture-funny-10.jpg'
                      : 'https://profilepicturesdp.com/wp-content/uploads/2018/06/default-profile-picture-funny-10.jpg',
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                )),
          ),
          Text(
            widget.user != null ? widget.user.displayName?? 'Batman' : 'Batman',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image:
                      'https://previews.123rf.com/images/coolvectorstock/coolvectorstock1808/coolvectorstock180803940/106920397-achievement-icon-vector-isolated-on-white-background-for-your-web-and-mobile-app-design-achievement-.jpg' ??
                          '',
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
                widget.signOut(context);
                widget.close();
              },
            ),
          ),
        ],
      ),
    );
  }
}
