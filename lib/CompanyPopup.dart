import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/CompanyPage.dart';
import 'package:flutter/material.dart';
import 'package:heave/blocs/company_popup/companypopup_bloc.dart';
import 'package:heave/blocs/company_popup/companypopup_state.dart';

class CompanyPopup extends StatelessWidget {
  const CompanyPopup({
    Key key,
    @required this.offset,
  }) : super(key: key);

  final Animation<Offset> offset;

  @override
  Widget build(BuildContext context) {
    final _companyPopupBloc = BlocProvider.of<CompanypopupBloc>(context);

    return BlocBuilder(
        bloc: _companyPopupBloc,
        builder: (BuildContext context, CompanypopupState state) {
          if (state is ActiveCompany) {
            return Align(
              alignment: Alignment.topCenter,
              child: SlideTransition(
                  position: offset,
                  child: Container(
                    padding: EdgeInsets.only(top: 30, right: 10, left: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Hero(
                                  tag: 'company_name',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      state.company['data']['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                            ),
                            Stack(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Hero(
                                      tag: 'company_image',
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.all(5),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    SpinKitPulse(
                                                      color: Colors.blueGrey,
                                                      size: 25.0,
                                                    ),
                                                imageUrl: state.company['data']
                                                        ['logo_url'] ??
                                                    'https://via.placeholder.com/140x100',
                                                fit: BoxFit.cover,
                                                height: 100,
                                                width: 100,
                                                fadeInDuration:
                                                    Duration(seconds: 1),
                                              ))),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          state.company['data']['accusations']
                                                  [0] ??
                                              '',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Positioned(
                                  bottom: 0,
                                  width: 35,
                                  right: 8,
                                  child: FloatingActionButton(
                                    heroTag: UniqueKey().toString(),
                                    elevation: 0,
                                    backgroundColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 500),
                                              pageBuilder: (_, __, ___) =>
                                                  CompanyPage(state.company)));
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 30,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
            );
          }
          return Container();
        });
  }
}
