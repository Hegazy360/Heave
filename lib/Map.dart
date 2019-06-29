// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong/latlong.dart';

// class Map extends StatefulWidget {
//   @override
//   _MapState createState() => _MapState();
// }

// typedef Marker MarkerUpdateAction(Marker marker);

// class _MapState extends State<Map> {
//   int _markerIdCounter = 1;

//   @override
//   void initState() {
//     super.initState();
//     _getMarkers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           child: FlutterMap(
//               options: MapOptions(
//             center: LatLng(51.5, -0.09),
//             zoom: 13.0,
//           )),
//         ),
//         Positioned(
//           bottom: 20,
//           right: 20,
//           child: FloatingActionButton(
//             backgroundColor: Colors.white,
//             onPressed: () {},
//             child: Icon(
//               Icons.add,
//               color: Colors.black,
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  @override
  void initState() {
    super.initState();
    _getMarkers();
    mapController = MapController();
  }

  _getMarkers() async {
    QuerySnapshot companiesSnapshot =
        await Firestore.instance.collection('companies').getDocuments();
    var companiesList = companiesSnapshot.documents;

    companiesList.forEach((company) {
      company.data['branches'].forEach((geoPoint) {
        print(geoPoint.latitude);
        print(geoPoint.longitude);

        // final MarkerId markerId = MarkerId(markerIdVal);
        // final Marker marker = Marker(
        //   markerId: markerId,
        //   position: LatLng(
        //     geoPoint.latitude,
        //     geoPoint.longitude,
        //   ),
        //   infoWindow: InfoWindow(title: company.data['name'], snippet: '*'),
        //   onTap: () {},
        // icon: BitmapDescriptor.fromBytes(),
        // );
        print(geoPoint.latitude);
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
          builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                      company['data']['logo_url'] ?? '',
                      fit: BoxFit.cover,
                    )),
              )

          // Container(
          //     decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         image: DecorationImage(
          //             fit: BoxFit.cover,
          //             image: NetworkImage(company['data']['logo_url'] ?? '')))),
          );
    }).toList();
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          center: LatLng(51.5, -0.09),
          zoom: 5.0,
          maxZoom: 10.0,
          minZoom: 3.0,
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
            padding: EdgeInsets.all(50),
          ),
          markers: markers,
          polygonOptions: PolygonOptions(
              borderColor: Colors.blueAccent,
              color: Colors.black12,
              borderStrokeWidth: 3),
          builder: (context, markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: null,
            );
          },
        ),
      ],
    );
  }
}
