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
  Animation<Offset> dateOffset;
  // AnimationController photoGrapherController;
  Animation<Offset> photoGrapherOffset;
  Animation<Offset> descriptionOffset;
  Animation<double> titleOpacity;
  Animation<double> descriptionOpacity;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    dateOffset =
        Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.5,
          1,
          curve: Curves.ease,
        ),
      ),
    );

    photoGrapherOffset =
        Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.5,
          1,
          curve: Curves.ease,
        ),
      ),
    );

    titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.5,
          1.000,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    descriptionOffset =
        Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );

    descriptionOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          1.000,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    controller.forward();
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
      body: SingleChildScrollView(
        child: Column(
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
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: SlideTransition(
                    position: dateOffset,
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
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SlideTransition(
                    position: photoGrapherOffset,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        widget.picture['photographer'],
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
            Align(
              alignment: Alignment.topRight,
              child: SlideTransition(
                position: photoGrapherOffset,
                child: Container(
                  width: 280,
                  padding: EdgeInsets.only(top: 5.0, right: 8.0, bottom: 8.0),
                  child: Text(
                    widget.picture['award'],
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: titleOpacity,
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  widget.picture['title'],
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
            ),
            FadeTransition(
              opacity: descriptionOpacity,
              child: SlideTransition(
                position: descriptionOffset,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Text(
                    widget.picture['description'],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.8),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
