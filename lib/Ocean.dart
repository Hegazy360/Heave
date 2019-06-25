import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doomsday/WebViewContainer.dart';

class Ocean extends StatefulWidget {
  @override
  _OceanState createState() => _OceanState();
}

class _OceanState extends State<Ocean> {
  List list = List();
  var isLoading = false;

  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "https://newsapi.org/v2/everything?q=ocean+waste&sortBy=popularity&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
    if (response.statusCode == 200) {
      list = json.decode(response.body)['articles'] as List;
      print(list);
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () =>
                      _handleURLButtonPress(context, list[index]['url']),
                  child: Card(
                      child: ListTile(
                    contentPadding: EdgeInsets.all(20.0),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(list[index]['title']),
                    ),
                    subtitle: Text(list[index]['description']),
                    trailing: Column(
                      children: <Widget>[
                        Expanded(
                            child: Image.network(
                          list[index]['urlToImage'] ?? '',
                          fit: BoxFit.cover,
                          height: 100.0,
                          width: 100.0,
                        )),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(list[index]['source']['name']),
                        )
                      ],
                    ),
                  )),
                );
              }),
    );
  }

  void _handleURLButtonPress(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }
}
