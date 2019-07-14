import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class MapInterface extends StatelessWidget {
  const MapInterface(
      {Key key,
      @required this.mapController,
      @required this.controller,
      @required this.markers,
      this.position})
      : super(key: key);

  final MapController mapController;
  final AnimationController controller;
  final List<Marker> markers;
  final position;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          center: position,
          zoom: 6.0,
          minZoom: 3.0,
          maxZoom: 10.0,
          onTap: (position) {
            switch (controller.status) {
              case AnimationStatus.completed:
                controller.reverse();
                break;
              default:
            }
          },
          onPositionChanged: (position, value, value2) {
            switch (controller.status) {
              case AnimationStatus.completed:
                controller.reverse();
                break;
              default:
            }
          },
          plugins: [
            MarkerClusterPlugin(),
          ]),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
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
    );
  }
}
