import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Animals extends StatefulWidget {
  @override
  _AnimalsState createState() => _AnimalsState();
}

class _AnimalsState extends State<Animals> {
  var animalsList;
  var isLoading = false;
  List colors = [Colors.greenAccent, Colors.orangeAccent,Colors.orangeAccent[400], Colors.orangeAccent[700],Colors.redAccent, Colors.redAccent[400]];

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
                      child: ListTile(
                    contentPadding: EdgeInsets.all(20.0),
                    title: Text(animalsList[index]['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                    subtitle: Text(animalsList[index]['status'] ?? 'Stable', style: TextStyle(color: Colors.white)),
                    trailing: Image.network(
                      animalsList[index]['image'] ?? '',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      height: 115.0,
                      width: 115.0,
                    ),
                  )),
                );
              }),
    );
  }
}
