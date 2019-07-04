import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doomsday/WebViewContainer.dart';
import 'package:intl/intl.dart';

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
        "https://newsapi.org/v2/everything?q=ocean+pollution+plastic&sortBy=publishedAt&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
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
                  onTap: () => _handleURLButtonPress(
                      context, list[index]['url'], list[index]['title']),
                  child: Card(
                      child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width * 2 / 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  list[index]['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(list[index]['description']),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Image.network(
                                list[index]['urlToImage']?? '',
                                fit: BoxFit.cover,
                                height: 100.0,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 15, bottom: 10),
                            child: Text(
                                DateFormat.yMMMd().format(
                                    DateTime.parse(list[index]['publishedAt'])),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 10),
                            child: Text(
                              list[index]['source']['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                );
              }),
    );
  }

  void _handleURLButtonPress(BuildContext context, String url, String title) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url, title)));
  }
}
