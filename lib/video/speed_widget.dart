import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_service.dart';

@immutable
class SpeedWidget extends StatelessWidget {
  final AudioPlayerHandler _audioHandler;

  const SpeedWidget(this._audioHandler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.white60,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("-1"),
                  Row(
                    children: [
                      const Text("Скорость: "),
                      StreamBuilder<double>(
                          stream: _audioHandler.playbackState
                              .map((state) => state.speed)
                              .distinct(),
                          builder: (context, snapshot) {
                            var speed = snapshot.data ?? 0.0;
                            return Text(speed.toStringAsFixed(2));
                          }),
                    ],
                  ),
                  const Text("+2"),
                ],
              ),
            ),
            StreamBuilder<double>(
                stream: _audioHandler.playbackState
                    .map((state) => state.speed)
                    .distinct(),
                builder: (context, snapshot) {
                  double rate = snapshot.data ?? 1.0;
                  return Slider(
                    min: 0,
                    max: 2,
                    value: rate,
                    onChanged: _audioHandler.setSpeed,
                  );
                })
          ],
        ),
      ),
    );
  }
}
