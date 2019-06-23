import 'package:doomsday/Map.dart';
import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doomsday',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(
            iconData: Icons.map,
            title: "Companies",
          ),
          TabData(
            iconData: Icons.directions_boat,
            title: "Ocean",
          ),
          TabData(iconData: Icons.wb_sunny, title: "Climate"),
          TabData(iconData: Icons.person, title: "Animals"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
      body: Center(
        child: _getPage(currentPage),
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return Map();
      case 1:
        return Text("Page2");
      case 2:
        return Text("Page3");
      default:
        return Text("Page4");
    }
  }
}
