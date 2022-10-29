import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_service.dart';

@immutable
class SleepTimerWidget extends StatefulWidget {
  final AudioPlayerHandler _audioHandler;

  const SleepTimerWidget(this._audioHandler, {Key? key}) : super(key: key);

  @override
  State<SleepTimerWidget> createState() => _SleepTimerWidgetState();
}

class _SleepTimerWidgetState extends State<SleepTimerWidget> {
  Duration _duration = const Duration(hours: 0, minutes: 30);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget._audioHandler.pauseAfterDelay(_duration);
        Navigator.of(context).pop();
        return false;
      },
      child: Container(
        height: 350,
        padding: EdgeInsets.all(24),
        color: Colors.white60,
        child: Column(
          children: [
            const Text("Таймер сна"),
            Center(
              child: DurationPicker(
                duration: _duration,
                onChange: (val) {
                  setState(() => _duration = val);
                },
                snapToMins: 5.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
