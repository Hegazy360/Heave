import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/blocs/animal_bloc/bloc.dart';

class Animals extends StatefulWidget {
  Animals(authenticated);

  @override
  _AnimalsState createState() => _AnimalsState();
}

class _AnimalsState extends State<Animals> {
  List colors = [
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.orangeAccent[400],
    Colors.orangeAccent[700],
    Colors.redAccent,
    Colors.redAccent[400]
  ];

  AnimalBloc _animalsBloc;

  @override
  void initState() {
    _animalsBloc = BlocProvider.of<AnimalBloc>(context);
    _animalsBloc.dispatch(FetchAnimals());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder(
          bloc: _animalsBloc,
          builder: (BuildContext context, AnimalState state) {
            if (state is AnimalsLoaded)
              return ListView.builder(
                  itemCount: state.animals.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => {},
                      child: Card(
                          color: colors[state.animals[index]['level']],
                          child: Card(
                              child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    width: MediaQuery.of(context).size.width *
                                        2 /
                                        3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          state.animals[index]['name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.0),
                                          child: Text(
                                              state.animals[index]['status'] ??
                                                  'Stable',
                                              style: TextStyle(
                                                  color: colors[state
                                                      .animals[index]['level']],
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 5.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            SpinKitPulse(
                                          color: Colors.blueGrey,
                                          size: 25.0,
                                        ),
                                        imageUrl: state.animals[index]
                                                ['image'] ??
                                            'https://via.placeholder.com/140x100',
                                        fit: BoxFit.cover,
                                        height: 120,
                                        fadeInDuration: Duration(seconds: 1),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ))),
                    );
                  });
            if (state is AnimalsUninitialized)
              return Center(child: CircularProgressIndicator());
            return Container();
          }),
    );
  }
}
