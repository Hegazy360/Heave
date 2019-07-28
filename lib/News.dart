import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heave/blocs/news_bloc/bloc.dart';
import 'package:heave/WebViewContainer.dart';
import 'package:heave/intro/News.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class News extends StatefulWidget {
  News(authenticated);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  NewsBloc _newsBloc;

  @override
  void initState() {
    _newsBloc = BlocProvider.of<NewsBloc>(context);
    _newsBloc.dispatch(FetchNews());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.blueGrey[300],
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  icon: Icon(Icons.wb_sunny),
                  child: Container(
                    child: Text('Climate Change'),
                  ),
                ),
                Tab(
                    icon: Icon(Icons.directions_boat),
                    child: Container(
                      child: Text('Plastic Pollution'),
                    )),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            BlocBuilder(
                bloc: _newsBloc,
                builder: (BuildContext context, NewsState state) {
                  if (state is NewsLoaded)
                    return TabBarView(
                      children: [
                        NewsList(newsList: state.climateNewsList),
                        NewsList(newsList: state.oceanNewsList),
                      ],
                    );
                  if (state is NewsUninitialized)
                    return Center(child: CircularProgressIndicator());
                  return Container();
                }),
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Icon(Icons.help_outline, color: Colors.blueGrey),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          duration: Duration(milliseconds: 400),
                          type: PageTransitionType.scale,
                          child: NewsIntro()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  const NewsList({
    Key key,
    @required this.newsList,
  }) : super(key: key);

  final List newsList;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => _handleURLButtonPress(
                  context, newsList[index]['url'], newsList[index]['title']),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100.0,
                ),
                child: Card(
                  child: CachedNetworkImage(
                    imageUrl: newsList[index]['urlToImage'] != null &&
                            newsList[index]['urlToImage'].isNotEmpty
                        ? newsList[index]['urlToImage']
                        : 'https://via.placeholder.com/140x100',
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: Colors.grey[900].withOpacity(0.55),
                        child: Column(
                          children: <Widget>[
                            Wrap(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(15),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          newsList[index]['title'] ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          newsList[index]['description'] ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 15, bottom: 10),
                                  child: Text(
                                      DateFormat.yMMMd().format(DateTime.parse(
                                          newsList[index]['publishedAt'])),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: 5, bottom: 10),
                                  child: Text(
                                    newsList[index]['source']['name'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    placeholder: (context, url) => SpinKitPulse(
                      color: Colors.blueGrey,
                      size: 25.0,
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.sentiment_very_dissatisfied, size: 30,),
                          Text("Something went wrong.")
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void _handleURLButtonPress(BuildContext context, String url, String title) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url, title)));
  }
}
