import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

extension FinderImageExt on CommonFinders {
  Finder byAssetImagePath(String assetName) {
    return byWidgetPredicate((widget) {
      if (widget is! Image) return false;
      final image = widget.image;
      if (image is! AssetImage) return false;
      return image.assetName == assetName;
    });
  }

  Finder byNetworkImagePath(String url) {
    return byWidgetPredicate((widget) {
      if (widget is! Image) return false;
      final image = widget.image;
      if (image is! NetworkImage) return false;
      return image.url == url;
    });
  }
}
