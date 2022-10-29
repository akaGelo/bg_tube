import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

final logger = Logger();

@immutable
class PlaceholderVideoWidget extends StatefulWidget {
  String? incomeUrl;

  PlaceholderVideoWidget(this.incomeUrl, {Key? key}) : super(key: key);

  @override
  State<PlaceholderVideoWidget> createState() => _PlaceholderVideoWidgetState();
}

class _PlaceholderVideoWidgetState extends State<PlaceholderVideoWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          _welcomeImage(),
          const SizedBox(height: 32),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: _centerText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeImage() {
    double imageHeight() {
      int f = null != widget.incomeUrl ? 4 : 2;
      return MediaQuery.of(context).size.height / f;
    }

    return GestureDetector(
      onTap: _mockPlaceholderStateChange,
      child: AnimatedContainer(
        height: imageHeight(),
        duration: Duration(milliseconds: 400),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: double.infinity,
                child: Center(
                    child: Image.asset('assets/placeholder.png',
                        width: double.infinity, height: double.infinity))),
            if (null == widget.incomeUrl)
              Positioned(
                bottom: -10,
                child: AvatarGlow(
                  glowColor: Colors.red,
                  endRadius: 90.0,
                  duration: Duration(milliseconds: 2000),
                  startDelay: Duration(milliseconds: 3000),
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Container(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _centerText(BuildContext context) {
    Widget _lessenText() {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Открой',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  width: 14,
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse("vnd.youtube://"),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Text(
                    'YouTube',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.redAccent),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 60,
              child: Icon(Icons.keyboard_double_arrow_down, size: 32),
            ),
            Text(
              'Поделись видео c этим приложением',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(
              height: 60,
              child: Icon(Icons.keyboard_double_arrow_down, size: 32),
            ),
            Text(
              'Слушай в фоне',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(
              height: 60,
              child: Icon(Icons.headphones_rounded, size: 32),
            )
          ]);
    }

    Widget _incomeUrlText(incomeUrl) {
      return Column(
          key: ValueKey(incomeUrl),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            AutoSizeText("Загружаем",
                maxLines: 2,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.headline4!,
                  child: AnimatedTextKit(repeatForever: true, animatedTexts: [
                    TypewriterAnimatedText(
                      widget.incomeUrl!,
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ]),
                )
              ],
            ),
          ]);
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeIn,
      child: (null == widget.incomeUrl)
          ? _lessenText()
          : _incomeUrlText(widget.incomeUrl),
    );
  }

  void _mockPlaceholderStateChange() {
    if (!kDebugMode) {
      return;
    }
    setState(() {
      if (null == widget.incomeUrl) {
        widget.incomeUrl = "https://youtu.be/fA6vHhXdg38";
      } else {
        widget.incomeUrl = null;
      }
    });
  }
}
