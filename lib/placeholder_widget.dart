import 'package:auto_size_text/auto_size_text.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlaceholderVideoWidget extends StatefulWidget {
  String? incomeUrl;

  PlaceholderVideoWidget(this.incomeUrl, {Key? key}) : super(key: key);

  @override
  PlaceholderVideoWidgetState createState() => PlaceholderVideoWidgetState();
}

class PlaceholderVideoWidgetState extends State<PlaceholderVideoWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (null != widget.incomeUrl) {
      return _loadingWidget(context);
    } else {
      return _welcomeWidget(context);
    }
  }

  Center _welcomeWidget(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 160),
          Container(
            height: 240,
            width: 240,
            padding: EdgeInsets.all(8),
            // Border width
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(
              child: SizedBox.fromSize(
                size: Size.fromRadius(48), // Image radius
                child: Image(
                    image: AssetImage('assets/logo.png'), fit: BoxFit.fill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• Открой приложение YouTube",
                    maxLines: 2, style: Theme.of(context).textTheme.headline6),
                Row(
                  children: [
                    Text("• Нажми поделиться видео ",
                        style: Theme.of(context).textTheme.headline6),
                    Icon(Icons.screen_share)
                  ],
                ),
                Text("• Выбери это приложение",
                    style: Theme.of(context).textTheme.headline6),
                Text("• Слушай в фоне, с выключенным дисплеем",
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),
          ),
        ],
      ),
    );
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
            AutoSizeText(widget.incomeUrl!,
                maxLines: 2,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center),
          ]),
    );
  }
}
