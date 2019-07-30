import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PicturePage extends StatefulWidget {
  final picture;
  const PicturePage(this.picture, {Key key}) : super(key: key);

  @override
  _PicturePageState createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    print("HEE");
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    offset = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero)
        .animate(controller);

    Future.delayed(Duration(milliseconds: 500), () {
      controller.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime pictureDate = DateTime.fromMillisecondsSinceEpoch(
        widget.picture['date'].seconds * 1000);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            child: Hero(
              tag: widget.picture['url'],
              child: CachedNetworkImage(
                imageUrl: widget.picture['url'] ??
                    'https://via.placeholder.com/140x100',
                fit: BoxFit.cover,
                fadeInDuration: Duration(seconds: 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SlideTransition(
              position: offset,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  DateFormat.yMMMMd().format(pictureDate),
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
