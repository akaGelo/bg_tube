import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bg_tube/placeholder/placeholder_widget.dart';
import 'package:bg_tube/video/video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:page_transition/page_transition.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'audio_service.dart';

final logger = Logger();

@immutable
class LoadingWidget extends StatefulWidget {
  final AudioPlayerHandler _audioHandler;

  const LoadingWidget(this._audioHandler, {Key? key}) : super(key: key);

  @override
  LoadingWidgetState createState() => LoadingWidgetState();
}

class LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  String? _incomeUrl; //ссылка из диалога поделиться

  @override
  void initState() {
    super.initState();

    ReceiveSharingIntent.getInitialText() // для открытого приложения
        .asStream()
        .listen(setIncomeLink, onError: showError);

    ReceiveSharingIntent.getTextStream() //для запуска
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
    if (!_setIncomeUrl(value)) {
      //нет изменений
      return;
    }
    widget._audioHandler.stop();

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        var video = await YoutubeExplode().videos.get(value);
        await precacheImage(
            CachedNetworkImageProvider(video.thumbnails.standardResUrl),
            context);
        await showVideoPlayer(video);
      } catch (e) {
        showError(e);
      }
    });
  }

  Future<void> showVideoPlayer(Video video) async {
    var result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topCenter,
            duration: Duration(milliseconds: 500),
            reverseDuration: Duration(milliseconds: 500),
            child: YtVideoWidget(
              video,
              widget._audioHandler,
              key: ValueKey(video),
            )));

    logger.w("Wideo player closed $result");
  }

  bool _setIncomeUrl(String? value) {
    bool isChange = _incomeUrl != value;
    setState(() {
      _incomeUrl = value;
    });
    return isChange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PlaceholderVideoWidget(_incomeUrl));
  }
}
