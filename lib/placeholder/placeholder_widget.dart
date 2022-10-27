import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
          const SizedBox(height: 32),
          welcomeImage(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: centerText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget welcomeImage() {
    double imageHeight() {
      int f = null != widget.incomeUrl ? 4 : 2;
      return MediaQuery.of(context).size.height / f;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (null == widget.incomeUrl) {
            widget.incomeUrl = "text";
          } else {
            widget.incomeUrl = null;
          }
        });
      },
      child: AnimatedContainer(
        height: imageHeight(),
        duration: Duration(milliseconds: 300),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                width: double.infinity,
                child: Center(
                    child: new Image.asset('assets/placeholder.png',
                        width: double.infinity, height: double.infinity))),
            if (null == widget.incomeUrl)
              Positioned(
                bottom: 20.0,
                child: AvatarGlow(
                  glowColor: Colors.red,
                  endRadius: 90.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  startDelay: Duration(milliseconds: 1000),
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

  Widget centerText(BuildContext context) {
    Widget lessenText() {
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
                    launchUrl(Uri.parse("vnd.youtube://"),mode: LaunchMode.externalApplication);
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

    Widget incomeUrlText(incomeUrl) {
      return Column(
          key: ValueKey(incomeUrl),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Загружаем", style: Theme.of(context).textTheme.headline4),
                SizedBox(
                  width: 30,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.headline4!,
                    child: AnimatedTextKit(repeatForever: true, animatedTexts: [
                      FadeAnimatedText('.'),
                      FadeAnimatedText('..'),
                      FadeAnimatedText('...'),
                    ]),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            AutoSizeText(incomeUrl!,
                maxLines: 2,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
          ]);
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeIn,
      child: (null == widget.incomeUrl)
          ? lessenText()
          : incomeUrlText(widget.incomeUrl),
    );
  }
}
