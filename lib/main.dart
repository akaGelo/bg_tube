import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:move_to_background/move_to_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AudioPlayerWidget(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  // final String url;
  // final bool isAsset;

  final String title;

  const AudioPlayerWidget(
      {Key? key,
      // required this.url, this.isAsset = false,
      this.title = "Title"})
      : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  int _counter = 0;
  late String title = "MyApp";
  late String _sharedText = "";
  late StreamSubscription _intentDataStreamSubscription;

  late AudioPlayer _audioPlayer;
  var _yt = YoutubeExplode();
  PlayerState _playerState = PlayerState.stopped;

  // bool get _isPlaying => _playerState == PlayerState.playing;
  // bool get _isLocal => !widget.url.contains('https');
  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        print(event);
        _playerState = PlayerState.stopped;
      });
    });
    //end audio

    initPlatformState();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        //https://youtu.be/sOOQSBCWZCI
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText()
        .then((value) => {
              setState(() {
                print(value);
                _sharedText = "test";
              })
            })
        .onError((error, stackTrace) {
      return {null};
    });
    // super.initState();
  }

  Future<void> _onBg() async {
    MoveToBackground.moveTaskToBack();
  }

  Future<void> initPlatformState() async {
    // You can provide either a video ID or URL as String or an instance of `VideoId`.
    var video = await _yt.videos.get(
        'https://youtube.com/watch?v=Dpp1sIL1m5Q'); // Returns a Video instance.

    var title = video.title; // "Scamazon Prime"
    var author = video.author; // "Jim Browning"
    var duration = video.duration; // Instance of Duration - 0:19:48.00000

    var manifest = await _yt.videos.streamsClient.getManifest('Dpp1sIL1m5Q');

    var audios = manifest.audioOnly.sortByBitrate();

    setState(() {
      print(audios);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _yt.close();
    super.dispose();
  }

  Future<void> _play() async {
    await _audioPlayer.play(UrlSource(
        "https://file-examples.com/storage/fe4b4c6261634c76e91986b/2017/11/file_example_MP3_700KB.mp3"));
    print("test");

    _onBg();

    // SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_playerState',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _play,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
