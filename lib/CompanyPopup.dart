import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/CompanyPage.dart';
import 'package:flutter/material.dart';
import 'package:heave/blocs/company_popup/companypopup_bloc.dart';
import 'package:heave/blocs/company_popup/companypopup_state.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class CompanyPopup extends StatelessWidget {
  const CompanyPopup({
    Key key,
    @required this.offset, this.markerLabelColors,
  }) : super(key: key);

  final Animation<Offset> offset;
  final List markerLabelColors;

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
                    padding: EdgeInsets.only(
                        top: 30, right: 10, left: 10, bottom: 0),
                    width: MediaQuery.of(context).size.width,
                    height: 250,
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
                              Row(
                                children: <Widget>[
                                  Hero(
                                    tag: 'company_image',
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.only(left: 15, right: 10, top: 10),
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
                                    child: Hero(
                                      tag: 'company_accusations',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            width: 200,
                                            child: Text(
                                              state.company['data']
                                                      ['accusations'][0] ??
                                                  '',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Hero(
                                        tag: 'company_level',
                                        child: Text(
                                          'Rank: ' + state.company['data']
                                                      ['level'].toString(),
                                          style: TextStyle(
                                              color: markerLabelColors[state.company['data']
                                                      ['level']],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      ButtonTheme(
                                        minWidth: 0,
                                        padding: EdgeInsets.all(0),
                                        child: RaisedButton(
                                            elevation: 0,
                                            color: Colors.white,
                                            onPressed: () {
                                              sendEmail();
                                            },
                                            child: Hero(
                                                tag: 'email_icon',
                                                child: Icon(
                                                  Icons.email,
                                                  size: 30,
                                                  color: Colors.blueGrey,
                                                ))),
                                      ),
                                      ButtonTheme(
                                        minWidth: 0,
                                        padding: EdgeInsets.all(0),
                                        child: RaisedButton(
                                          elevation: 0,
                                          color: Colors.white,
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    duration: Duration(
                                                        milliseconds: 700),
                                                    type:
                                                        PageTransitionType.fade,
                                                    child: CompanyPage(
                                                        state.company)));
                                          },
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 30,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                  )),
            );
          }
          return Container();
        });
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: ['test@test.com'],
      cc: ['m.hegazy94@hotmail.com'],
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print(error.toString());
    }
  }
}
