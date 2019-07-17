import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:heave/WebViewContainer.dart';
import 'package:intl/intl.dart';

class News extends StatefulWidget {
  News(authenticated);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  List climateNewsList = List();
  List oceanNewsList = List();
  var isLoading = false;

  _fetchClimateNews() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "https://newsapi.org/v2/everything?q=global+warming&sortBy=publishedAt&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
    if (response.statusCode == 200) {
      setState(() {
        climateNewsList = json.decode(response.body)['articles'] as List;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  _fetchOceanNews() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "https://newsapi.org/v2/everything?q=ocean+pollution+plastic&sortBy=publishedAt&apiKey=fcd8f6cd8c2a4eebb48c9bd9de8e3dae");
    if (response.statusCode == 200) {
      setState(() {
        oceanNewsList = json.decode(response.body)['articles'] as List;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  void initState() {
    _fetchClimateNews();
    _fetchOceanNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("News", style: TextStyle(color: Colors.black),),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.blueGrey,
            unselectedLabelColor: Colors.black45,
            tabs: [
              Tab(icon: Icon(Icons.wb_sunny)),
              Tab(icon: Icon(Icons.directions_boat)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NewsList(isLoading: isLoading, newsList: climateNewsList),
            NewsList(isLoading: isLoading, newsList: oceanNewsList),
          ],
        ),
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  const NewsList({
    Key key,
    @required this.isLoading,
    @required this.newsList,
  }) : super(key: key);

  final bool isLoading;
  final List newsList;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => _handleURLButtonPress(context,
                      newsList[index]['url'], newsList[index]['title']),
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
                                  newsList[index]['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(newsList[index]['description']),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => SpinKitPulse(
                                      color: Colors.blueGrey,
                                      size: 25.0,
                                    ),
                                imageUrl:
                                    newsList[index]['urlToImage'].isNotEmpty
                                        ? newsList[index]['urlToImage']
                                        : 'https://via.placeholder.com/140x100',
                                errorWidget: (context, url, _) =>
                                    Icon(Icons.error, color: Colors.red),
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
                                DateFormat.yMMMd().format(DateTime.parse(
                                    newsList[index]['publishedAt'])),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 10),
                            child: Text(
                              newsList[index]['source']['name'],
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
