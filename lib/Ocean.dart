import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pictures extends StatefulWidget {
  Pictures(authenticated);

  @override
  _PicturesState createState() => _PicturesState();
}

class _PicturesState extends State<Pictures> {
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
      child: Center(
              child: CircularProgressIndicator(),
            )
    );
  }

}
