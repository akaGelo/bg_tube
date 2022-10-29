import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bg_tube/ext/yt_ext.dart';
import 'package:bg_tube/video/sleeptimer_widget.dart';
import 'package:bg_tube/video/speed_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:rxdart/rxdart.dart' show Rx;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_service.dart';

final logger = Logger();

const int exitErrorCode = -1;

@immutable
class YtVideoWidget extends StatefulWidget {
  final Video video;
  final AudioPlayerHandler _audioHandler;

  const YtVideoWidget(this.video, this._audioHandler, {Key? key})
      : super(key: key);

  @override
  _YtWidgetState createState() => _YtWidgetState();
}

class _YtWidgetState extends State<YtVideoWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late StreamSubscription<PlaybackState> _stateListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    widget._audioHandler.playAudio(widget.video);
    _stateListener = widget._audioHandler.playbackState.stream.listen((event) {
      if (event.processingState == AudioProcessingState.idle &&
          event.position.inSeconds > 1) {
        //пришла новая ссылка -> нажата кнопка стоп после начала
        Navigator.pop(context, AudioProcessingState.idle);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //при повторном открытии надо закрывтаь окно плеера. служба в фоне живет и состояние плеера сохранятся
      // даже если смахнуть приложение
      closeIfNotPlay();
    }
  }

  Future<void> closeIfNotPlay() async {
    var lastState = widget._audioHandler.lastState();
    if (ProcessingState.completed  == lastState.processingState) {
      widget._audioHandler.stop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stateListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _goToBackground,
          tooltip: 'Back ',
          child: const Icon(Icons.u_turn_left_sharp),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            _coverWidget(),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ..._titles(),
                    const SizedBox(height: 20),
                    _actionButtonsRow(context),
                    _audioProgress(),
                    const SizedBox(height: 8),
                    _videoDescription(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _titles() {
    return <Widget>[
      AutoSizeText(widget.video.title,
          maxLines: 3,
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center),
      const SizedBox(height: 16),
      AutoSizeText(widget.video.author,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center)
    ];
  }

  Expanded _videoDescription() {
    return Expanded(
        child: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(widget.video.description),
    )));
  }

  Widget _coverWidget() {
    var width = MediaQuery.of(context).size.width;
    var height = (width * 9) / 16;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              image: CachedNetworkImageProvider(
                  widget.video.thumbnails.noBorderPreview),
            ),
          ),
        ),
        Positioned(
            left: -width / 4,
            child: _moveButton(
                width,
                height,
                Icons.keyboard_double_arrow_left_rounded,
                EdgeInsets.only(left: width / 4),
                () => widget._audioHandler.moveToLeft())),
        Positioned(
            right: -width / 4,
            child: _moveButton(
                width,
                height,
                Icons.keyboard_double_arrow_right_rounded,
                EdgeInsets.only(right: width / 4),
                () => widget._audioHandler.moveToRight())),
      ],
    );
  }

  ClipOval _moveButton(
      double width, double height, IconData icon, EdgeInsets edge, onTap) {
    return ClipOval(
      child: Material(
        color: Colors.white12, // Button color
        child: InkWell(
          splashColor: Colors.white60, // Splash color
          onTap: onTap,
          child: SizedBox(
              width: width / 1.5,
              height: height * 2,
              child: Padding(
                padding: edge,
                child: Icon(
                  icon,
                  color: Colors.white60,
                  size: 64,
                ),
              )),
        ),
      ),
    );
  }

  Widget _button(IconData iconData, VoidCallback onPressed) {
    return SizedBox(
      height: 64,
      width: 64,
      child: IconButton(
        icon: Icon(iconData),
        color: Colors.black87,
        iconSize: 48.0,
        onPressed: onPressed,
      ),
    );
  }

  Widget _playPauseLoadingIcon() {
    return SizedBox(
      height: 64,
      width: 80,
      child: StreamBuilder<PlaybackState>(
          stream: widget._audioHandler.playbackState,
          builder: (context, snapshot) {
            bool playing = snapshot.data?.playing ?? false;
            AudioProcessingState state = snapshot.data?.processingState ??
                AudioProcessingState.buffering;
            logger.i("state $state");
            if (state == AudioProcessingState.buffering ||
                state == AudioProcessingState.loading ||
                state == AudioProcessingState.idle) {
              return _bufferingIndicator();
            }
            if (playing) {
              if (state == AudioProcessingState.completed) {
                return _button(
                    Icons.refresh, widget._audioHandler.playFromStart);
              } else {
                return _button(Icons.pause, widget._audioHandler.pause);
              }
            } else {
              return _button(Icons.play_arrow, widget._audioHandler.play);
            }
          }),
    );
  }

  Widget _bufferingIndicator() {
    return const SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      ),
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

  StreamBuilder<PositionData> _audioProgress() {
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

  Row _actionButtonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_sleepTimerIcon(), _playPauseLoadingIcon(), _speedIcon()],
    );
  }

  InkWell _sleepTimerIcon() {
    return InkWell(
      onTap: _showSleepTimerModal,
      child: Column(
        children: [
          const Icon(Icons.timer, color: Colors.grey),
          StreamBuilder<Duration>(
              stream: widget._audioHandler.sleepTimerState,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return Text(
                  duration.inMinuteFormat,
                  style: Theme.of(context).textTheme.labelSmall,
                );
              }),
        ],
      ),
    );
  }

  InkWell _speedIcon() {
    return InkWell(
      onTap: _showSpeedModal,
      child: Column(
        children: [
          const Icon(Icons.speed, color: Colors.grey),
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
    );
  }

  Future<void> _showSpeedModal() async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SpeedWidget(widget._audioHandler);
        });
  }

  Future<void> _showSleepTimerModal() async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SleepTimerWidget(widget._audioHandler);
        });
  }

  Future<void> _goToBackground() async {
    return MoveToBackground.moveTaskToBack();
  }
}
