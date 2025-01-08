import 'dart:typed_data';

import 'package:chabok_front/extensions/list.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/main_fab.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/toast.dart';
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
        'Real estate',
        'Automobile',
        'Digital & Electronics',
        'Kitchenware',
        'Personal Items',
        'Entertainment',
        'Others',
      ],
    ),
    'status': OptionsTextFieldViewModel(
      icon: Icons.production_quantity_limits,
      required: true,
      label: 'Status',
      options: ['for sale', 'sold', 'reserved'],
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

  String get action => throw UnimplementedError('Should be overridden!');

  @override
  State<CreateEditProductPage> createState() => _CreateEditProductPageState();

  void submit(
    BuildContext context, {
    required Map<String, TextFieldViewModel> fields,
    Map<String, Uint8List?>? images,
  }) {
    throw UnimplementedError('Should be overridden!');
  }
}

class _CreateEditProductPageState extends State<CreateEditProductPage> {
  late Map<String, Uint8List> images;

  Map<String, TextFieldViewModel> get fields => widget.fields;

  final formKey = GlobalKey<FormState>();

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
        label: widget.action,
        icon: Icons.check,
        onPressed: submit,
      ),
      body: Center(
        child: CardWidget(
          child: Form(
            key: formKey,
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
      ),
    );
  }

  void submit() {
    if (images.isEmpty) {
      CustomToast.showToast(
        context,
        ServerResponse.visualize(
          '{"message": "Please upload at least one image for your product."}',
          400,
        ),
      );
      return;
    }
    if (formKey.currentState?.validate() ?? false) {
      widget.submit(context, fields: fields, images: images);
    }
  }
}

class CreateProductPage extends CreateEditProductPage {
  CreateProductPage({super.key})
      : super(fieldsInitialValues: {
          'status': 'for sale',
          'name': 'product.name',
          'category': 'Others',
          'city_name': 'product.location',
          'price': '12321876312',
          'description': 'product.description',
        }) {
    fields['status']?.readOnly = true;
  }

  @override
  String get action => 'Create Product';

  @override
  Future<void> submit(
    BuildContext context, {
    required Map<String, TextFieldViewModel> fields,
    Map<String, Uint8List?>? images,
  }) async {
    ProductService.instance.createProduct(
      fields.map((k, vm) {
        var text = vm.controller.text;
        if (k == 'price') text = text.replaceAll(',', '');
        return MapEntry(k, text);
      }),
      images,
    ).then((response) {
      if (response.isOk) {
        CustomToast.showToast(context, response);
        RouterService.go('/');
      }
    });
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
            'price': product.price.toString(),
            'description': product.description,
            'status': product.status,
          },
          images: product.imageUrls.asMap().map((_, im) => MapEntry(im, null)),
        );

  @override
  String get action => 'Edit Product';

  @override
  void submit(
    BuildContext context, {
    required Map<String, TextFieldViewModel> fields,
    Map<String, Uint8List?>? images,
  }) {
    ProductService.instance.editProduct(
      fields.map((k, vm) {
        var text = vm.controller.text;
        if (k == 'price') text = text.replaceAll(',', '');
        return MapEntry(k, text);
      }),
      images,
    ).then((response) {
      if (response.isOk) {
        CustomToast.showToast(context, response);
        RouterService.go('/');
      }
    });
  }
}
