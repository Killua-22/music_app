import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../pages/detailspage.dart';
import 'details.dart';

class MusicDetailBloc {
  final _repository = Repository();
  final _trackId = PublishSubject<int>();
  final _lyrics = BehaviorSubject<Future<lyrics>>();

  Function(int) get fetchTracksById => _trackId.sink.add;
  Stream<Future<lyrics>> get movieTracks => _lyrics.stream;

  MusicDetailBloc() {
    _trackId.stream.transform(_itemTransformer()).pipe(_lyrics);
  }

  dispose() async {
    _trackId.close();
    await _lyrics.drain();
    _lyrics.close();
  }

  _itemTransformer() {
    return ScanStreamTransformer((Future<lyrics> trailer, int id, int index) {
      print(index);
      trailer = _repository.fetchLyrics(id);
      return trailer;
    }, emptyFuturelyrics());
  }

  Future<lyrics> emptyFuturelyrics() async {
    throw Null;
  }
}

class MusicDetailBlocProvider extends InheritedWidget {
  final MusicDetailBloc bloc;

  MusicDetailBlocProvider({Key? key, Widget? child})
      : bloc = MusicDetailBloc(),
        super(key: key, child: child!);

  @override
  bool updateShouldNotify(_) {
    return true;
  }

  static MusicDetailBloc of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<MusicDetailBlocProvider>())!
        .bloc;
  }
}
