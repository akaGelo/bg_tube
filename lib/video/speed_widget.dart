import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_service.dart';

class SpeedWidget extends StatefulWidget {
  AudioPlayerHandler _audioHandler;

  SpeedWidget(this._audioHandler, {Key? key}) : super(key: key);

  @override
  _SpeedWidgetState createState() => _SpeedWidgetState();
}

class _SpeedWidgetState extends State<SpeedWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("-3"),
                  Text("0"),
                  Text("+3"),
                ],
              ),
            ),
            StreamBuilder<double>(
                stream: widget._audioHandler.playbackState
                    .map((state) => state.speed)
                    .distinct(),
                builder: (context, snapshot) {
                  double rate = snapshot.data ?? 1.0;
                  return Slider(
                    min: -3,
                    max: 4,
                    value: rate,
                    onChanged: widget._audioHandler.setSpeed,
                  );
                })
          ],
        ),
      ),
    );
  }
}
