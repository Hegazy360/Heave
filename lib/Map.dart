import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'CompanyPage.dart';

class Map extends StatefulWidget {
  static const String route = 'map_controller_animated';

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<Map> with TickerProviderStateMixin {
  MapController mapController;
  List tappedPoints = [];
  AnimationController controller;
  Animation<Offset> offset;
  var activeCompany;

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
                      child: Image.network(
                        company['data']['logo_url'] ?? '',
                        fit: BoxFit.cover,
                      )),
                ),
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
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )),
                              ),
                              Stack(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Hero(
                                          tag: 'company_image',
                                          child: Image.network(
                                            activeCompany['data']['logo_url'] ??
                                                '',
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
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
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
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
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "info",
              backgroundColor: Colors.white,
              onPressed: () {},
              child: Icon(
                Icons.remove_red_eye,
                color: Colors.blueGrey,
              ),
            )),
        Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              heroTag: "add",
              backgroundColor: Colors.white,
              onPressed: () {},
              child: Icon(
                Icons.add,
                color: Colors.blueGrey,
              ),
            )),
      ],
    );
  }
}
