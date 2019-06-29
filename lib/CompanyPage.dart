import 'package:flutter/material.dart';

class CompanyPage extends StatefulWidget {
  final company;
  const CompanyPage({
    Key key,
    this.company,
  }) : super(key: key);
  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sources'),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Hero(
                  tag: 'company_name',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(widget.company['data']['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                Hero(
                  tag: 'company_image',
                  child: Image.network(
                    widget.company['data']['logo_url'] ?? '',
                    fit: BoxFit.cover,
                    height: 130,
                    width: 130,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
