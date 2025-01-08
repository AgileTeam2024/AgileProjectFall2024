import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ImagesDisplayWidget extends StatefulWidget {
  final List<String> imageUrls;

  const ImagesDisplayWidget(this.imageUrls, {super.key});

  @override
  State<ImagesDisplayWidget> createState() => _ImagesDisplayWidgetState();
}

class _ImagesDisplayWidgetState extends State<ImagesDisplayWidget> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;
    if (imageUrls.isEmpty) {
      return ErrorPage(
        errorCode: 404,
        message: 'No images :(',
      );
    }
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return Flex(
      direction: isBigScreen ? Axis.vertical : Axis.horizontal,
      spacing: 15,
      children: [
        SelectedImageDisplay(
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
              return SmallImageWidget(
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

@visibleForTesting
class SelectedImageDisplay extends StatelessWidget {
  final String image;

  final void Function()? onNext, onPrev;

  const SelectedImageDisplay(
    this.image, {
    super.key,
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

@visibleForTesting
class SmallImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final void Function() select;

  const SmallImageWidget({
    super.key,
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
