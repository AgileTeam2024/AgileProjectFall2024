import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ImagesDisplayWidget extends StatefulWidget {
  final List<String> imageUrls;

  ImagesDisplayWidget(this.imageUrls, {super.key})
      : assert(imageUrls.isNotEmpty);

  @override
  State<ImagesDisplayWidget> createState() => _ImagesDisplayWidgetState();
}

class _ImagesDisplayWidgetState extends State<ImagesDisplayWidget> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return Flex(
      direction: isBigScreen ? Axis.vertical : Axis.horizontal,
      children: [
        _SelectedImageDisplay(
          imageUrls[selected],
          onNext: imageCount == 1 ? null : () => _select(selected + 1),
          onPrev: imageCount == 1 ? null : () => _select(selected - 1),
        ),
      ],
    );
  }

  int get imageCount => widget.imageUrls.length;

  void _select(int idx) {
    selected = (idx + imageCount) % imageCount;
    setState(() {});
  }
}

class _SelectedImageDisplay extends StatelessWidget {
  final String image;

  final void Function()? onNext, onPrev;

  const _SelectedImageDisplay(
    this.image, {
    this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(image),
        Align(
          alignment: Alignment.centerRight,
          child: Button.icon(
            icon: Icons.navigate_next,
            onPressed: onNext,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Button.icon(
            icon: Icons.navigate_before,
            onPressed: onPrev,
          ),
        ),
      ],
    );
  }
}
