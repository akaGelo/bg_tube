import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bg_tube/placeholder_widget.dart';
import 'package:bg_tube/video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'audio_service.dart';

@immutable
class MainWidget extends StatefulWidget {
  final AudioPlayerHandler _audioHandler;

  const MainWidget(this._audioHandler, {Key? key}) : super(key: key);

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget>
    with SingleTickerProviderStateMixin {
  Video? _video; // загружаемое видео
  String? _incomeUrl; //ссылка из диалога поделиться

  @override
  void initState() {
    super.initState();

    ReceiveSharingIntent.getInitialText() // on start app
        .asStream()
        .listen(setIncomeLink, onError: showError);

    ReceiveSharingIntent.getTextStream() //for started app
        .listen(setIncomeLink, onError: showError);
  }

  void showError(err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.badUrl),
    ));
  }

  Future<void> setIncomeLink(String? value) async {
    if (null == value) {
      return;
    }

    setState(() {
      _incomeUrl = value;
    });

    try {
      var video = await YoutubeExplode().videos.get(value);
      setState(() {
        _video = video;
      });
    } catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
      floatingActionButton: null != _video
          ? FloatingActionButton(
              onPressed: () => MoveToBackground.moveTaskToBack(),
              tooltip: 'Back ',
              child: const Icon(Icons.u_turn_left_sharp),
            )
          : Container(),
    );
  }

  Widget _body(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1.2, 0), end: const Offset(0, 0))
                .animate(animation),
            child: child);
      },
      duration: const Duration(milliseconds: 500),
      child: _video is Video
          ? YtVideoWidget(
              _video!,
              widget._audioHandler,
              key: ValueKey(_video),
            )
          : PlaceholderVideoWidget(_incomeUrl),
    );
  }
}
