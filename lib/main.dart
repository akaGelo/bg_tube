import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'audio_service.dart';
import 'main_widget.dart';

void main() async {
  var _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(BgTubeApp(_audioHandler));
}

class BgTubeApp extends StatelessWidget {
  AudioPlayerHandler _audioHandler;

  BgTubeApp(this._audioHandler, {super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: MaterialApp(
        title: "test",
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ru', ''),
        ],
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: MainWidget(_audioHandler),
      ),
    );
  }
}
