import 'package:heave/CompanyPage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CompanyPopup extends StatelessWidget {
  const CompanyPopup({
    Key key,
    @required this.offset,
    @required this.activeCompany,
  }) : super(key: key);

  final Animation<Offset> offset;
  final activeCompany;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
            position: offset,
            child: Container(
              padding:
                  EdgeInsets.only(top: 30, right: 10, left: 10),
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
                                        child: FadeInImage
                                            .memoryNetwork(
                                          placeholder:
                                              kTransparentImage,
                                          image: activeCompany[
                                                      'data']
                                                  ['logo_url'] ??
                                              '',
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                        )
                                        )),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(8.0),
                                  child: Text(
                                    activeCompany['data']
                                            ['accusations'][0] ??
                                        '',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w400),
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
      );
  }
}