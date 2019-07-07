import 'package:heave/WebViewContainer.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:transparent_image/transparent_image.dart';

class CompanyPage extends StatefulWidget {
  final company;
  const CompanyPage({
    Key key,
    this.company,
  }) : super(key: key);
  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blueGrey,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Sources',
          style: TextStyle(color: Colors.blueGrey),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Hero(
                  tag: 'company_name',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(widget.company['data']['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                Hero(
                    tag: 'company_image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(0),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: widget.company['data']['logo_url'] ?? '',
                            fit: BoxFit.cover,
                            height: 130,
                            width: 130,
                          )),
                    ))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.company['data']['sources'].length,
              itemBuilder: (_, index) {
                return widget.company['data']['sources'][index]['type'] ==
                        'video'
                    ? Column(
                        children: <Widget>[
                          Text(
                              widget.company['data']['sources'][index]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10.0),
                            child: Text(widget.company['data']['sources'][index]
                                ['publisher']),
                          ),
                          YoutubePlayer(
                            context: context,
                            source: widget.company['data']['sources'][index]
                                ['value'],
                            quality: YoutubeQuality.HD,
                            autoPlay: false,
                          )
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 10, left: 10, right: 10),
                        child: Column(
                          children: <Widget>[
                            Text(
                                widget.company['data']['sources'][index]
                                    ['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(widget.company['data']['sources']
                                  [index]['publisher']),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: FlatButton.icon(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  color: Colors.black.withOpacity(0.1),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    WebViewContainer(
                                                        widget.company['data']
                                                                ['sources']
                                                            [index]['value'],
                                                        widget.company['data']
                                                                ['sources']
                                                            [index]['title'])));
                                  },
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blueGrey,
                                  ),
                                  label: Text('View Article')),
                            )
                          ],
                        ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
