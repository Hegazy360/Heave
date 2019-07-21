import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/blocs/picture_bloc/bloc.dart';
import 'package:heave/blocs/picture_bloc/picture_bloc.dart';
import 'package:heave/intro/Pictures.dart';
import 'package:page_transition/page_transition.dart';

class Pictures extends StatefulWidget {
  Pictures(authenticated);

  @override
  _PicturesState createState() => _PicturesState();
}

class _PicturesState extends State<Pictures> {
  PictureBloc _pictureBloc;

  @override
  void initState() {
    _pictureBloc = BlocProvider.of<PictureBloc>(context);
    _pictureBloc.dispatch(FetchPictures());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BlocBuilder(
            bloc: _pictureBloc,
            builder: (BuildContext context, PictureState state) {
              if (state is PicturesLoaded)
                return ListView.builder(
                    itemCount: state.pictures.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          child: CachedNetworkImage(
                        placeholder: (context, url) => SpinKitPulse(
                          color: Colors.blueGrey,
                          size: 25.0,
                        ),
                        imageUrl: state.pictures[index]['url'] ??
                            'https://via.placeholder.com/140x100',
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(seconds: 1),
                      ));
                    });
              if (state is PicturesUninitialized)
                return Center(child: CircularProgressIndicator());
              return Container();
            }),
        Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.help_outline, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        duration: Duration(milliseconds: 500),
                        type: PageTransitionType.fade,
                        child: PicturesIntro()));
              },
            )),
      ],
    );
  }
}
