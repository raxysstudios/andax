import 'package:flutter/material.dart';

class OptionItem {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  OptionItem(
    this.icon,
    this.text, {
    this.onTap,
  });
}

class OptionsButton extends StatelessWidget {
  const OptionsButton(
    this.options, {
    this.icon = Icons.more_vert_outlined,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final List<OptionItem> options;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: Icon(icon),
      itemBuilder: (context) {
        return [
          for (final option in options)
            PopupMenuItem(
              onTap: option.onTap,
              child: Row(
                children: [
                  Icon(option.icon),
                  const SizedBox(width: 16),
                  Text(option.text),
                ],
              ),
            ),
        ];
      },
    );
  }
}
