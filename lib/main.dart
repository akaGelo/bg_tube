import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';

import 'main_widget.dart';

void main() {
  runApp(const BgTubeApp());
}

class BgTubeApp extends StatelessWidget {
  const BgTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: MaterialApp(
        title: 'BgTube',
        theme: ThemeData(
            primarySwatch: Colors.amber,
            ),
        home: MainWidget(),
      ),
    );
  }
}
