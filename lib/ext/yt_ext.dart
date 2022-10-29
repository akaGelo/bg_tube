import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension NoBorderURls on ThumbnailSet {
  String get noBorderPreview =>
      "https://img.youtube.com/vi/$videoId/mqdefault.jpg";
}

extension FormatDuration on Duration {
  String get inMinuteFormat =>
      "${inMinutes.remainder(60).toString().padLeft(2, "0")}:${inSeconds.remainder(60).toString().padLeft(2, "0")}";
}
