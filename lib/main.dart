import 'package:heave/Map.dart';
import 'package:heave/Ocean.dart';
import 'package:flutter/material.dart';
import 'package:heave/Animals.dart';
import 'package:heave/GlobalWarming.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'heave',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
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
          TabData(iconData: Icons.wb_sunny, title: "Climate"),
          TabData(
            iconData: Icons.directions_boat,
            title: "Ocean",
          ),
          TabData(iconData: Icons.person, title: "Animals"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
      body: IndexedStack(
        index: currentPage,
        children: <Widget>[Map(), GlobalWarming(), Ocean(), Animals()],
      ),
    );
  }

// Center(
//         child: _getPage(currentPage),
//       )

}
