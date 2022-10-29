import 'dart:async';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/src/videos/video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration? duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  final BehaviorSubject<Duration> sleepTimerState =
      BehaviorSubject.seeded(Duration(seconds: 0));

  Timer? _sleepTimer;

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() {
    AppMetrica.reportEvent('Start player');
    return _player.play();
  }

  @override
  Future<void> pause() {
    AppMetrica.reportEvent('Pause player');
    return _player.pause();
  }

  void pauseAfterDelay(Duration duration) {
    AppMetrica.reportEventWithMap('Pause pause after delay', {'duration': duration.inMinutes});
    _sleepTimer?.cancel();

    if (duration.inSeconds < 1) {
      _sleepTimer?.cancel();
      sleepTimerState.add(Duration.zero);
      return; // выключаем таймер
    }
    sleepTimerState.add(duration);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      sleepTimerState.add(Duration(seconds: duration.inSeconds - timer.tick));

      if (timer.tick >= duration.inSeconds) {
        pause();
        timer.cancel();
      }
    });
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    AppMetrica.reportEvent('Stop player');
    _sleepTimer?.cancel();
    await _player.stop();
    return _player.seek(Duration.zero);
  }

  @override
  Future<void> setSpeed(double speed) {
    AppMetrica.reportEventWithMap('Set speed', {'speed': speed});
    return _player.setSpeed(speed);
  }

  Future<void> moveToLeft() {
    var pos = _player.position.inSeconds - 10;
    if (pos < 0) {
      pos = 0;
    }
    return _player.seek(Duration(seconds: pos));
  }

  Future<void> moveToRight() {
    var pos = _player.position.inSeconds + 10;
    return _player.seek(Duration(seconds: pos));
  }

  Future<void> playAudio(Video video) async {
    AppMetrica.reportEventWithMap('Play audio', {
      'url': video.url,
      'author': video.author,
      'title': video.title,
      'keywords': video.keywords
    });
    var manifest = await _yt.videos.streamsClient.getManifest(video.id);
    var sortByBitrate = manifest.audioOnly.sortByBitrate();
    var audio = await sortByBitrate.last;

    var item = MediaItem(
        id: audio.url.toString(),
        title: video.title,
        artist: video.author,
        artUri: Uri.parse(video.thumbnails.lowResUrl),
        duration: video.duration);
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(audio.url));
    return _player.play();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
