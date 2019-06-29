import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Animals extends StatefulWidget {
  @override
  _AnimalsState createState() => _AnimalsState();
}

class _AnimalsState extends State<Animals> {
  var animalsList;
  var isLoading = false;
  List colors = [
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.orangeAccent[400],
    Colors.orangeAccent[700],
    Colors.redAccent,
    Colors.redAccent[400]
  ];

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  _fetchAnimals() async {
    setState(() {
      isLoading = true;
    });
    await Firestore.instance
        .collection('animals')
        .orderBy("level", descending: true)
        .getDocuments()
        .then((animalsSnapshot) {
      setState(() {
        animalsList = animalsSnapshot.documents;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: animalsList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => {},
                  child: Card(
                      color: colors[animalsList[index]['level']],
                      child: Card(
                          child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(15),
                                width:
                                    MediaQuery.of(context).size.width * 2 / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      animalsList[index]['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                          animalsList[index]['status'] ??
                                              'Stable',
                                          style: TextStyle(
                                              color: colors[animalsList[index]
                                                  ['level']], fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Image.network(
                                    animalsList[index]['image'] ?? '',
                                    fit: BoxFit.cover,
                                    height: 120,
                                  ),
                                ),
                              )
                            ],
                          ),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: <Widget>[
                          //     Padding(
                          //       padding: EdgeInsets.only(left: 15, bottom: 10),
                          //       child: Text(
                          //           DateFormat.yMMMd().format(
                          //               DateTime.parse(list[index]['publishedAt'])),
                          //           style: TextStyle(fontWeight: FontWeight.bold)),
                          //     ),
                          //     Padding(
                          //       padding: EdgeInsets.only(right: 5, bottom: 10),
                          //       child: Text(
                          //         list[index]['source']['name'],
                          //         style: TextStyle(fontWeight: FontWeight.bold),
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ],
                      ))

                      //     ListTile(
                      //   contentPadding: EdgeInsets.all(20.0),
                      //   title: Text(animalsList[index]['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                      //   subtitle: Text(animalsList[index]['status'] ?? 'Stable', style: TextStyle(color: Colors.white)),
                      //   trailing: Image.network(
                      //     animalsList[index]['image'] ?? '',
                      //     fit: BoxFit.cover,
                      //     alignment: Alignment.center,
                      //     height: 115.0,
                      //     width: 115.0,
                      //   ),
                      // )
                      ),
                );
              }),
    );
  }
}
