import 'package:flutter/material.dart';

class OptionItem {
  late final Widget widget;
  final VoidCallback? onTap;

  OptionItem(
    this.widget, [
    this.onTap,
  ]);

  OptionItem.simple(
    IconData icon,
    String text, [
    this.onTap,
  ]) : widget = Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon),
            const SizedBox(width: 16),
            Text(text),
            const SizedBox(width: 16),
          ],
        );
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
    return ListTileTheme(
      data: const ListTileThemeData(horizontalTitleGap: 0),
      child: PopupMenuButton<int>(
        icon: Icon(icon),
        onSelected: (i) => options[i].onTap?.call(),
        itemBuilder: (context) {
          return [
            for (var i = 0; i < options.length; i++)
              PopupMenuItem(
                padding: EdgeInsets.zero,
                value: i,
                child: options[i].widget,
              ),
          ];
        },
      ),
    );
  }
}
