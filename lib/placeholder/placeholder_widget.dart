import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:bg_tube/placeholder/lesson_widget.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
class PlaceholderVideoWidget extends StatelessWidget {
  String? incomeUrl;

  PlaceholderVideoWidget(this.incomeUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (null != incomeUrl)
        ? _loadingWidget(context)
        : LessonWidget(incomeUrl);
  }


  Center _loadingWidget(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 160),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  height: 240,
                  width: 240,
                  padding: EdgeInsets.all(8),
                  // Border width
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: Size.fromRadius(48), // Image radius
                      child: Image(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
                SizedBox(
                  child: CircularProgressIndicator(),
                  height: 240.0,
                  width: 240.0,
                )
              ],
            ),
            const SizedBox(height: 120),
            Text("Скоро будем слушать",
                style: Theme.of(context).textTheme.headline4),
            const SizedBox(height: 24),
            AutoSizeText(incomeUrl!,
                maxLines: 2,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
          ]),
    );
  }
}
