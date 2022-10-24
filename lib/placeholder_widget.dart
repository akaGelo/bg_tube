import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
      return Center(
        child: Column(children: [
          // Text(widget.incomeUrl),
          Text("Загружаем"),
          Text(widget.incomeUrl!),
        ]),
      );
    } else {
      return Center(
        child: new Text("Статическая Документация по первому старту"),
      );
    }
  }
}
