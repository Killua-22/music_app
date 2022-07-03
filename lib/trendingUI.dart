import 'package:flutter/material.dart';
import 'package:music_app/pages/bookmarkpage.dart';
import 'trendingbloc.dart';
import 'music_details_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import '../pages/trendingpage.dart';
import 'detailsUI.dart';

class Trending extends StatefulWidget {
  @override
  State<Trending> createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  @override
  void initState() {
    super.initState();
    bloc.fetchAllMusic();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc.fetchAllMusic();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "Trending",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: PopupMenuButton<int>(
              onSelected: (value) {
                if (value == 1) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => BookmarkUI()));
                }
              },
              child: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text("Bookmarks"),
                )
              ],
            ),
          )
        ],
      ),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return Center(
            child: connected
                ? startListing()
                : Text(
                    'No Internet Connection',
                  ),
          );
        },
        child: Container(),
      ),
    );
  }

  Widget startListing() {
    bloc.fetchAllMusic();
    return StreamBuilder(
      stream: bloc.allMusic,
      builder: (context, AsyncSnapshot<trendingItems> snapshot) {
        if (snapshot.hasData) {
          return buildList(snapshot);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildList(AsyncSnapshot<trendingItems> snapshot) {
    return ListView.builder(
        itemCount: snapshot.data!.results.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Card(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.library_music,
                      color: Colors.black26,
                      size: 28,
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                          snapshot.data!.results[index].track_name.toString()),
                      subtitle: Text(
                          snapshot.data!.results[index].album_name.toString()),
                    ),
                    flex: 7,
                  ),
                  Expanded(
                    child: ListTile(
                      trailing: Text(
                          snapshot.data!.results[index].artist_name.toString()),
                    ),
                    flex: 3,
                  )
                ],
              ),
            ),
            onTap: () => openDetailPage(snapshot.data!, index),
          );
        });
  }

  openDetailPage(trendingItems data, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MusicDetailBlocProvider(
          child: detailsUI(
              artist_name: data.results[index].artist_name,
              track_name: data.results[index].track_name,
              album_name: data.results[index].album_name,
              explicit: data.results[index].explicit,
              track_rating: data.results[index].track_rating,
              track_id: data.results[index].track_id!),
        );
      }),
    );
  }
}
