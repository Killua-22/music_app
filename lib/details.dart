import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import '../pages/trendingpage.dart';
import '../pages/detailspage.dart';

class trendingAPIProvider {
  Client client = Client();

  Future<trendingItems> fetchMusicList() async {
    print("entered");
    final response = await client.get(Uri.parse(
        "https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=88d0aa649a7f6ca5e60d88282ff9b360"));
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return trendingItems.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Future<lyrics> fetchLyrics(int track_id) async {
    final response = await client.get(Uri.parse(
        "https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=$track_id&apikey=88d0aa649a7f6ca5e60d88282ff9b360"));

    if (response.statusCode == 200) {
      return lyrics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load trailers');
    }
  }
}

class Repository {
  final musicApiProvider = trendingAPIProvider();

  Future<trendingItems> fetchAllMusic() => musicApiProvider.fetchMusicList();
  Future<lyrics> fetchLyrics(int track_id) =>
      musicApiProvider.fetchLyrics(track_id);
}
