import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bg_tube/video/speed_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:rxdart/rxdart.dart';

import '../audio_service.dart';

// import 'audio_service_common.dart';
// import 'main3.dart';

class YtVideoWidget extends StatefulWidget {
  Video video;
  AudioPlayerHandler _audioHandler;

  YtVideoWidget(this.video, this._audioHandler, {Key? key}) : super(key: key);

  @override
  _YtWidgetState createState() => _YtWidgetState();
}

class _YtWidgetState extends State<YtVideoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _playPauseAnimationController;

  @override
  void initState() {
    super.initState();
    widget._audioHandler.playAudio(widget.video);
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    super.dispose();
  }

  Widget _coverWidget() {
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: widget.video.thumbnails.standardResUrl,
            imageBuilder: (context, imageProvider) => DropShadowImage(
              offset: Offset(0, 2),
              scale: 1,
              blurRadius: 4,
              borderRadius: 8,
              image: Image(
                image: imageProvider,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
        icon: Icon(iconData),
        iconSize: 64.0,
        onPressed: onPressed,
      );

  Widget _centralIcon() {
    return SizedBox(
      height: 64,
      width: 80,
      child: StreamBuilder<PlaybackState>(
        stream: widget._audioHandler.playbackState,
        builder: (context, snapshot) {
          if (null == snapshot.data) {
            return _loadingIndicator();
          }
          bool playing = snapshot.data!.playing;

          var processingState =
              snapshot.data!.processingState ?? AudioProcessingState.idle;
          if (AudioProcessingState.ready != processingState) {
            return _loadingIndicator();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (playing)
                _button(Icons.pause, widget._audioHandler.pause)
              else
                _button(Icons.play_arrow, widget._audioHandler.play),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          MoveToBackground.moveTaskToBack();
          // Navigator.pop(context);
        },
        tooltip: 'Back ',
        child: const Icon(Icons.u_turn_left_sharp),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: <Widget>[
            _coverWidget(),
            AutoSizeText(widget.video.title,
                maxLines: 3,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AutoSizeText(widget.video.author,
                maxLines: 1,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _buttons_row(context),
            _audioPprogress(),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  StreamBuilder<PositionData> _audioPprogress() {
    return StreamBuilder<PositionData>(
      stream: _mediaStateStream,
      builder: (context, snapshot) {
        final positionState = snapshot.data;
        return ProgressBar(
          progress: positionState?.position ?? Duration.zero,
          buffered: positionState?.bufferedPosition ?? Duration.zero,
          total: positionState?.duration ?? Duration.zero,
          onSeek: (position) {
            widget._audioHandler.seek(position);
          },
        );
      },
    );
  }

  Row _buttons_row(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Icon(Icons.timer, color: Colors.grey),
            Text("00:00", style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        _centralIcon(),
        InkWell(
          child: Column(
            children: [
              Icon(Icons.speed, color: Colors.grey),
              StreamBuilder<double>(
                  stream: widget._audioHandler.playbackState
                      .map((state) => state.speed)
                      .distinct(),
                  builder: (context, snapshot) {
                    final speed = snapshot.data ?? 0;
                    return Text(
                      speed.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }),
            ],
          ),
          onTap: () => _showSpeedModal(),
        )
      ],
    );
  }

  Stream<PositionData> get _mediaStateStream {
    return Rx.combineLatest3<MediaItem?, PlaybackState, Duration, PositionData>(
        widget._audioHandler.mediaItem,
        widget._audioHandler.playbackState,
        AudioService.position, (mediaItem, playbackState, position) {
      return PositionData(
          position, playbackState.bufferedPosition, mediaItem!.duration);
    });
  }

  Future<void> _showSpeedModal() async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SpeedWidget(widget._audioHandler);
        });
  }

  Widget _loadingIndicator() {
    return SizedBox(
      height: 64,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
