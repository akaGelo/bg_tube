import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:bg_tube/placeholder/placeholder_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
class LessonWidget extends StatelessWidget {
  String? incomeUrl;

  LessonWidget(this.incomeUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  width: double.infinity,
                  height: 444.0,
                  child: Center(
                      child: new Image.asset('assets/placeholder.png',
                          width: double.infinity, height: double.infinity))),
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
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
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
                          onPressed: () {},
                          child: Text(
                            'YouTube',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5!.copyWith(decoration: TextDecoration.underline,color: Colors.redAccent),
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
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
