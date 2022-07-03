import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:music_app/detailsUI.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkUI extends StatefulWidget {
  const BookmarkUI({Key? key}) : super(key: key);

  @override
  State<BookmarkUI> createState() => _BookmarkUIState();
}

class _BookmarkUIState extends State<BookmarkUI> {
  final List<String?> tracknames = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "Bookmarks",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      // body: Row(
      //   children: [
      //     for (var track in tracknames) Text("$track"),
      //     SizedBox(
      //       height: 10,
      //     )
      //   ],
      // ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data != null) {
            print('Shared preferences has some data');
            return Row(
              children: [
                for (var tracks in tracknames)
                  Text(
                    snapshot.data.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                //name
              ],
            );
          }
          print('snapshot is empty.');
          return Container();
        },
      ),
    );
  }

  Future<List> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    tracknames.add(prefs.getString('trackname'));
    return tracknames;
  }
}
