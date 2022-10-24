import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bg_tube/placeholder_widget.dart';
import 'package:bg_tube/video_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget>
    with SingleTickerProviderStateMixin {
  Video? _video; // загружаемое видео
  String? _incomeUrl; //ссылка из диалога поделиться

  @override
  void initState() {
    ReceiveSharingIntent.getTextStream() //for running
        .listen((String value) => setIncomeLink(value), onError: (err) {
      showError();
    });

    ReceiveSharingIntent.getInitialText() // for start
        .then((value) => setIncomeLink(value))
        .onError((error, stackTrace) {
      showError();
    });

    // Future.delayed(Duration(seconds: 2),
    //     () => setIncomeLink("https://www.youtube.com/watch?v=BMCNZ9ciO3Y"));
  }

  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Load url problem"),
    ));
  }

  Future<void> setIncomeLink(String? value) async {
    if (null == value) {
      return;
    }

    setState(() {
      if (null != value) _incomeUrl = value;
    });

    try {
      var video = await YoutubeExplode().videos.get(value);
      setState(() {
        _video = video;
      });
    } catch (e) {
      showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
      floatingActionButton: _video is Video
          ? FloatingActionButton(
              onPressed: () => MoveToBackground.moveTaskToBack(),
              tooltip: 'Back ',
              child: const Icon(Icons.u_turn_left_sharp),
            )
          : Container(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _body(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1500),
      child: _video is Video
          ? YtVideoWidget(_video!)
          : PlaceholderVideoWidget(_incomeUrl),
    );
  }
}
