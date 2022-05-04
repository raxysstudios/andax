import 'package:andax/models/image_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/shared/widgets/editor_sheet.dart';
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
      void setAlignment(Alignment? v) => setState(
            () => image.alignment = v ?? image.alignment,
          );
      return [
        ListTile(
          leading: const Icon(Icons.link_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Image file URL',
            ),
            autofocus: true,
            initialValue: image.url,
            validator: emptyValidator,
            onChanged: (s) => image.url = s.trim(),
          ),
        ),
        buildExplanationTile(
          context,
          'Image height',
        ),
        Slider(
          value: image.height,
          min: 64,
          max: 256,
          divisions: 3,
          label: image.height.toString(),
          onChanged: (v) => setState(() => image.height = v),
        ),
        buildExplanationTile(
          context,
          'Image fit mode',
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
        buildExplanationTile(
          context,
          'Image alignment (anchor)',
        ),
        RadioListTile<Alignment>(
          value: Alignment.topCenter,
          groupValue: image.alignment,
          title: const Text('Top'),
          secondary: const Icon(Icons.vertical_align_top_rounded),
          onChanged: setAlignment,
        ),
        RadioListTile<Alignment>(
          value: Alignment.center,
          groupValue: image.alignment,
          title: const Text('Center'),
          secondary: const Icon(Icons.vertical_align_center_rounded),
          onChanged: setAlignment,
        ),
        RadioListTile<Alignment>(
          value: Alignment.bottomCenter,
          groupValue: image.alignment,
          title: const Text('Bottom'),
          secondary: const Icon(Icons.vertical_align_bottom_rounded),
          onChanged: setAlignment,
        ),
      ];
    },
  );
}
