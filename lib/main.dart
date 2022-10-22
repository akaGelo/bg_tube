import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioPlayerWidget(title: 'Flutter Demo Home Page'),
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

  late AudioPlayer _audioPlayer;
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
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _audioPlayer.play(UrlSource(
        "https://file-examples.com/storage/fe4b4c6261634c76e91986b/2017/11/file_example_MP3_700KB.mp3"));
    print("test");
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
