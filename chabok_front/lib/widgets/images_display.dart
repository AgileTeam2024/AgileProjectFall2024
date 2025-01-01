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
      spacing: 15,
      children: [
        _SelectedImageDisplay(
          imageUrls[selected],
          onNext: imageCount == 1 ? null : () => _select(selected + 1),
          onPrev: imageCount == 1 ? null : () => _select(selected - 1),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: imageCount,
            itemBuilder: (context, index) {
              return _SmallImageWidget(
                imageUrl: imageUrls[index],
                isSelected: index == selected,
                select: () => _select(index),
              );
            },
          ),
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
        Positioned(
          right: 0,
          child: Button.icon(
            icon: Icons.navigate_next,
            onPressed: onNext,
          ),
        ),
        Positioned(
          left: 0,
          child: Button.icon(
            icon: Icons.navigate_before,
            onPressed: onPrev,
          ),
        ),
      ],
    );
  }
}

class _SmallImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final void Function() select;

  const _SmallImageWidget({
    required this.imageUrl,
    required this.isSelected,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: select,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Theme.of(context).primaryColor,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
            ],
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
