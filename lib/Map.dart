import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

typedef Marker MarkerUpdateAction(Marker marker);

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  var markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _getMarkers();
  }

  _getMarkers() async {
    QuerySnapshot companiesSnapshot =
        await Firestore.instance.collection('companies').getDocuments();
    var companiesList = companiesSnapshot.documents;

    companiesList.forEach((company) {
      company.data['branches'].forEach((geoPoint) {
        print(geoPoint.latitude);
        print(geoPoint.longitude);
        final String markerIdVal = 'marker_id_$_markerIdCounter';
        _markerIdCounter++;
        final MarkerId markerId = MarkerId(markerIdVal);

        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            geoPoint.latitude,
            geoPoint.longitude,
          ),
          infoWindow: InfoWindow(title: company.data['name'], snippet: '*'),
          onTap: () {
            print("marker clicked");
          },
        );

        setState(() {
          markers[markerId] = marker;
        });
      });
      print('HERE');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set<Marker>.of(markers.values)
    ));
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId("marker_1"),
        position: LatLng(37.42796133580664, -122.085749655962),
      ),
    ].toSet();
  }
}
