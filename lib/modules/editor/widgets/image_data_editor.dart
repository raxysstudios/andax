import 'package:andax/models/image_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';

Future<ImageData?> showImageDataEditor(BuildContext context, Node node) async {
  ImageData image = node.image == null
      ? ImageData()
      : ImageData.fromJson(node.image!.toJson());

  return showEditorSheet<ImageData>(
    context: context,
    title: 'Setup image',
    initial: node.image,
    onSave: () => node.image = image,
    onDelete: () => node.image = null,
    builder: (_, setState) {
      void setFit(BoxFit? v) => setState(() => image.fit = v ?? image.fit);
      return [
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Image file URL',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            autofocus: true,
            initialValue: image.url,
            validator: emptyValidator,
            onChanged: (s) => image.url = s.trim(),
          ),
        ),
        buildExplanationTile(
          context,
          'Image fit mode',
          'Controls the appearance',
        ),
        RadioListTile<BoxFit>(
          value: BoxFit.cover,
          groupValue: image.fit,
          title: const Text('Fit'),
          onChanged: setFit,
        ),
        RadioListTile<BoxFit>(
          value: BoxFit.contain,
          groupValue: image.fit,
          title: const Text('Contain'),
          onChanged: setFit,
        ),
      ];
    },
  );
}
