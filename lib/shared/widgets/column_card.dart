import 'package:flutter/material.dart';

class ColumnCard extends StatelessWidget {
  const ColumnCard({
    required this.children,
    this.title,
    this.subtitle,
    this.divider = true,
    this.margin = const EdgeInsets.only(top: 12),
    Key? key,
  }) : super(key: key);

  final EdgeInsets margin;
  final String? title;
  final String? subtitle;
  final bool divider;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Card(
      margin: margin,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || subtitle != null) ...[
            const SizedBox(height: 8),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  title!,
                  style: theme.bodyText1,
                ),
              ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  subtitle!,
                  style: theme.bodyText2,
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (divider)
            for (final c in children) ...[c, const Divider()]
          else
            ...children,
        ],
      ),
    );
  }
}
