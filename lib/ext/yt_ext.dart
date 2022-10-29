import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension NoBorderURls on ThumbnailSet {
  String get noBorderPreview =>
      "https://img.youtube.com/vi/$videoId/mqdefault.jpg";
}
