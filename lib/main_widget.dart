import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bg_tube/placeholder/placeholder_widget.dart';
import 'package:bg_tube/video/video_widget.dart';
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
      await precacheImage(
          CachedNetworkImageProvider(video.thumbnails.standardResUrl), context);

      var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Scaffold(body: YtVideoWidget(video, widget._audioHandler))),
      );

      setState(() {
        _incomeUrl = null;
      });
    } catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PlaceholderVideoWidget(_incomeUrl));
  }
}
