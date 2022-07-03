import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'music_details_bloc.dart';
import '../pages/detailspage.dart';
import 'package:flutter_offline/flutter_offline.dart';
import '../pages/bookmarkpage.dart';

class detailsUI extends StatefulWidget {
  final String? artist_name;
  final String? track_name;
  final String? album_name;
  final String? explicit;
  final String? track_rating;
  final int track_id;

  detailsUI(
      {this.artist_name,
      this.track_name,
      this.album_name,
      this.explicit,
      this.track_rating,
      required this.track_id});

  @override
  State<StatefulWidget> createState() {
    return detailsUIState(
        artist_name: artist_name.toString(),
        track_name: track_name.toString(),
        album_name: album_name.toString(),
        explicit: explicit.toString(),
        track_rating: track_rating.toString(),
        track_id: track_id);
  }
}

class detailsUIState extends State<detailsUI> {
  late String? artist_name;
  late String? track_name;
  late String? album_name;
  late String? explicit;
  late String? track_rating;
  late int track_id;

  MusicDetailBloc bloc = MusicDetailBloc();

  detailsUIState(
      {this.artist_name,
      this.track_name,
      this.album_name,
      this.explicit,
      this.track_rating,
      required this.track_id});

  bool _isFavourite = false;

  late SharedPreferences s_prefs;
  String temp = '';

  void _toogleFavourite() {
    setState(() {
      if (_isFavourite)
        _isFavourite = false;
      else {
        _isFavourite = true;
        setData();
      }
    });
  }

  Future<void> setData() async {
    s_prefs = await SharedPreferences.getInstance();
    s_prefs.setString('trackid', '$track_id');
    s_prefs.setString('trackname', '$track_name');
  }

  @override
  void didChangeDependencies() {
    bloc = MusicDetailBlocProvider.of(context);
    bloc.fetchTracksById(track_id);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = '$track_name';
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text("Track Details", style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: ((_isFavourite)
                      ? const Icon(Icons.bookmark)
                      : const Icon(Icons.bookmark_border)),
                  color: Colors.black,
                  onPressed: _toogleFavourite,
                )),
          ]),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          return Center(
            child: connected
                ? SafeArea(
                    child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Name',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('$track_name',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 20),
                              Text(
                                'Artist',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('$artist_name',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 20),
                              Text(
                                'Album Name',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('$album_name',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 20),
                              Text(
                                'Explicit',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('$explicit', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 20),
                              Text(
                                'Rating',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('$track_rating',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 20),
                              Text(
                                'Lyrics',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0)),
                              StreamBuilder(
                                stream: bloc.movieTracks,
                                builder: (context,
                                    AsyncSnapshot<Future<lyrics>> snapshot) {
                                  if (snapshot.hasData) {
                                    return FutureBuilder(
                                      future: snapshot.data,
                                      builder: (context,
                                          AsyncSnapshot<lyrics> itemSnapShot) {
                                        if (itemSnapShot.hasData) {
                                          if (itemSnapShot
                                                  .data!.results.length >
                                              0) {
                                            return trackLayout(
                                                itemSnapShot.data!);
                                          } else {
                                            return noTrack(itemSnapShot.data!);
                                          }
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ))
                : Text(
                    'No Internet Connection',
                  ),
          );
        },
        child: Container(),
      ),
    );
  }
}

Widget noTrack(lyrics data) {
  return Center(
    child: Container(
      child: Text("No trailer available"),
    ),
  );
}

Widget trackLayout(lyrics data) {
  if (data.results.length > 1) {
    return Row(
      children: <Widget>[
        trackItem(data, 0),
        trackItem(data, 1),
      ],
    );
  } else {
    return Row(
      children: <Widget>[
        trackItem(data, 0),
      ],
    );
  }
}

trackItem(lyrics data, int index) {
  return Expanded(
    child: Column(
      children: <Widget>[
        Text(data.results[index].lyrics_body!, style: TextStyle(fontSize: 20)),
      ],
    ),
  );
}
