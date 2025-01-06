import 'dart:typed_data';

import 'package:chabok_front/extensions/list.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/main_fab.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/upload_file.dart';
import 'package:flutter/material.dart';

class CreateEditProductPage extends StatefulWidget {
  final Map<String, Uint8List?>? images;
  final Map<String, TextFieldViewModel> fields = {
    'name': TextFieldViewModel(
      icon: Icons.abc,
      required: true,
      label: 'Product Name',
    ),
    'category': OptionsTextFieldViewModel(
      icon: Icons.category,
      required: true,
      label: 'Category',
      options: [
        'Real-Estate',
        'Automobile',
        'Digital & Electronics',
        'Kitchenware',
        'Personal Items',
        'Others'
      ],
    ),
    'city_name': TextFieldViewModel(
      icon: Icons.pin_drop,
      required: false,
      label: 'Location',
    ),
    'price': MoneyTextFieldViewModel(
      required: true,
      label: 'Price',
    ),
    'description': TextFieldViewModel(
      icon: Icons.description,
      required: true,
      label: 'Description',
      maxLines: 4,
    ),
  };

  CreateEditProductPage({
    super.key,
    Map<String, String?>? fieldsInitialValues,
    this.images,
  }) {
    if (fieldsInitialValues != null) {
      fieldsInitialValues
          .forEach((k, v) => fields[k]?.controller.text = v ?? '');
    }
  }

  @override
  State<CreateEditProductPage> createState() => _CreateEditProductPageState();

  void submit() {
    throw UnimplementedError('Should be overridden!');
  }
}

class _CreateEditProductPageState extends State<CreateEditProductPage> {
  late final Map<String, Uint8List> images;

  Map<String, TextFieldViewModel> get fields => widget.fields;

  final _networkService = NetworkService.instance;

  @override
  void initState() {
    super.initState();
    images = {};
    widget.images?.keys.forEach((path) async {
      images[path] = await _networkService.getImage(path);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return Scaffold(
      floatingActionButton: MainFAB(
        icon: Icons.check,
        onPressed: widget.submit,
      ),
      body: Center(
        child: CardWidget(
          child: Flex(
            direction: isBigScreen ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: UploadFileWidget(
                  files: images,
                  onFilesChange: (newFiles) =>
                      setState(() => images = newFiles),
                  minimumFiles: 1,
                  maximumFiles: 10,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: isBigScreen ? VerticalDivider() : Divider(),
              ),
              Expanded(
                child: isBigScreen
                    ? Column(
                        children: fields.values
                            .map(
                              (vm) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7.5,
                                  horizontal: 10,
                                ),
                                child: CustomTextField(vm),
                              ),
                            )
                            .toList(),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 15,
                        children: fields.values
                            .toList()
                            .fixedGrouped(groupSize: 2)
                            .map(
                              (vmList) => Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 20,
                                children: vmList
                                    .map(
                                      (vm) => Expanded(
                                        child: CustomTextField(vm),
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateProductPage extends CreateEditProductPage {
  CreateProductPage({super.key});

  @override
  void submit() {
    // curl --location 'http://185.231.59.87/api/product/create' \
    // --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTczNjExMTEwOCwianRpIjoiMmU1N2MxNjYtZjU3YS00MjU5LThkMDYtYmIxNWNjNzQ3ZjllIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImRvcnJpbiIsIm5iZiI6MTczNjExMTEwOCwiY3NyZiI6Ijc3ZTRmNjcyLTRiZWMtNDE0Yi05YzkxLWFjNWZmNTQ5ZDM4ZSIsImV4cCI6MTczNjExNDcwOH0.htdQwYUmhktkTEBdEwZh92-L7GWl31tCVW8mYdpFw_k' \
    // --form 'name="product name 8"' \
    // --form 'price="1023445"' \
    // --form 'city_name="Tehran, Iran"' \
    // --form 'description="My product is a good product :)"' \
    // --form 'status="for sale"' \
    // --form 'category="Electronics"' \
    // --form 'picture=@"/Users/dorrinsotoudeh/Downloads/IMG_552278780ADD-1.jpeg"' \
    // --form 'picture=@"/Users/dorrinsotoudeh/Downloads/1403-10-03 16.22.08 copy.jpg"'


  }
}

class EditProductPage extends CreateEditProductPage {
  final Product product;

  EditProductPage(this.product, {super.key})
      : super(
          fieldsInitialValues: {
            'name': product.name,
            'category': product.category,
            'city_name': product.location,
            'price': product.price?.toString(),
            'description': product.description,
          },
          images: product.imageUrls.asMap().map((_, im) => MapEntry(im, null)),
        );

  @override
  void submit() {
    // todo edit product in back
  }
}
