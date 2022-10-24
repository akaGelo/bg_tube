import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bg_tube/speed_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtVideoWidget extends StatefulWidget {
  Video video;

  YtVideoWidget(this.video, {Key? key}) : super(key: key);

  @override
  YtWidgetState createState() => YtWidgetState();
}

class YtWidgetState extends State<YtVideoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _playPauseAnimationController;
  late YoutubeExplode _yt;
  late AudioPlayer _audioPlayer;

  // late HttpClient httpClient = HttpClient();

  PlayerState? _playerState;

  late Duration _position = Duration.zero;
  late double _playbackRate = 1.0;
  Duration? _duration;

  List<StreamSubscription> _audioStreamSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _yt = YoutubeExplode();
    _playPauseAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _audioStreamSubscriptions
        .add(_audioPlayer.onPlayerStateChanged.listen(_onStateChange));
    _audioStreamSubscriptions
        .add(_audioPlayer.onPositionChanged.listen(_onPositionsChange));
    _audioStreamSubscriptions
        .add(_audioPlayer.onDurationChanged.listen(_onDurationLoad));

    initSourceAndPlayer();
  }

  void _onStateChange(PlayerState s) {
    setState(() {
      _playerState = s;
      if (_playerState == PlayerState.completed) {
        _audioPlayer.stop();
        _playPauseAnimationController.reverse();
        _position == Duration.zero;
        _duration == null;
        initSourceAndPlayer();
      }
    });
  }

  void _onPositionsChange(event) {
    setState(() {
      _position = event;
    });
  }

  void _onSetPlaybackRate(rate) {
    setState(() {
      _playbackRate = rate;
    });
    _audioPlayer.setPlaybackRate(rate);
  }

  void _onDurationLoad(event) {
    if (null != _duration) {
      return;
    }

    setState(() {
      _playerState = PlayerState.stopped;
      _duration = event;
    });
    _playOnTap();
  }

  @override
  void dispose() {
    _audioStreamSubscriptions.forEach((element) => element.cancel());
    _yt.close();
    _playPauseAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _coverWidget() {
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: widget.video.thumbnails.standardResUrl,
            imageBuilder: (context, imageProvider) => DropShadowImage(
              offset: Offset(0, 8),
              scale: 1,
              blurRadius: 12,
              borderRadius: 20,
              image: Image(
                image: imageProvider,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playOnTap() {
    if (PlayerState.playing == _playerState) {
      _playPauseAnimationController.reverse();
      _audioPlayer.pause();
    } else {
      _playPauseAnimationController.forward();
      _audioPlayer.resume();
    }
  }

  Widget _centralIcon() {
    if (null != _playerState) {
      return InkWell(
        onTap: _playOnTap,
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _playPauseAnimationController,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[
          _coverWidget(),
          const SizedBox(height: 16),
          AutoSizeText(widget.video.title,
              maxLines: 2,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          AutoSizeText(widget.video.author,
              maxLines: 1,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(Icons.timer, color: Colors.grey),
                  Text(0.00.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              _centralIcon(),
              InkWell(
                child: Column(
                  children: [
                    Icon(Icons.speed, color: Colors.grey),
                    Text(_playbackRate.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                onTap: () => _showSpeedModal(),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (null != _duration &&
                  (PlayerState.playing == _playerState ||
                      PlayerState.paused == _playerState))
                Text(_formatDuration(_position))
              else
                Text(""), // отступ, что б не дергалось ничего
              if (null != _duration) Text(_formatDuration(_duration!)),
            ],
          ),
          LinearProgressIndicator(
            value: _progress(),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  double _progress() {
    if (null == _duration) {
      return 0;
    }
    return _position.inSeconds / _duration!.inSeconds;
  }

  Future<void> initSourceAndPlayer() async {
    var manifest = await _yt.videos.streamsClient.getManifest(widget.video.id);
    var sortByBitrate = manifest.audioOnly.sortByBitrate();
    var url = await sortByBitrate.last.url;
    _audioPlayer.setSource(UrlSource(url.toString()));
  }

  String _formatDuration(Duration duration) {
    String str = duration.toString();
    int d = str.lastIndexOf(".");
    return str.substring(0, d);
  }

  Future<void> _showSpeedModal() async {
    double rate = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SpeedWidget(_playbackRate);
        });
    _onSetPlaybackRate(rate);
  }
}
