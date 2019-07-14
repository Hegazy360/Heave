import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/WebViewContainer.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

class CompanyPage extends StatelessWidget {
  final company;

  CompanyPage(this.company);

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
                    child: Text(company['data']['name'],
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
                          child: CachedNetworkImage(
                            placeholder: (context, url) => SpinKitPulse(
                                  color: Colors.blueGrey,
                                  size: 25.0,
                                ),
                            imageUrl: company['data']['logo_url'] ??
                                'https://via.placeholder.com/140x100',
                            fit: BoxFit.cover,
                            height: 130,
                            width: 130,
                            fadeInDuration: Duration(seconds: 1),
                          )),
                    ))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: company['data']['sources'].length,
              itemBuilder: (_, index) {
                return company['data']['sources'][index]['type'] == 'video'
                    ? Column(
                        children: <Widget>[
                          Text(company['data']['sources'][index]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10.0),
                            child: Text(
                                company['data']['sources'][index]['publisher']),
                          ),
                          YoutubePlayer(
                            context: context,
                            source: company['data']['sources'][index]['value'],
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
                            Text(company['data']['sources'][index]['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(company['data']['sources'][index]
                                  ['publisher']),
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
                                            builder: (context) =>
                                                WebViewContainer(
                                                    company['data']['sources']
                                                        [index]['value'],
                                                    company['data']['sources']
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

// class CompanyPage extends StatelessWidget {
//   final company;
//   const CompanyPage({
//     Key key,
//     this.company,
//   }) : super(key: key);
//   @override
//   _CompanyPageState createState() => _CompanyPageState();
// }
