import 'package:andax/shared/widgets/options_button.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'raxys_logo.dart';

class RaxysButton extends StatelessWidget {
  const RaxysButton({Key? key}) : super(key: key);

  void link(String url) => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    return OptionsButton(
      [
        OptionItem(
          const ListTile(
            leading: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.send_rounded),
            ),
            title: Text('Developer Contact'),
            subtitle: Text('Raxys Studios'),
          ),
          () => link('https://t.me/raxysstudios'),
        ),
        OptionItem(
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              var info = 'Loading...';
              final package = snapshot.data;
              if (package != null) {
                info = 'v${package.version} • b${package.buildNumber}';
              }
              return ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.code_rounded),
                ),
                title: const Text('GitHub Repository'),
                subtitle: Text(info),
              );
            },
          ),
          () => link('https://github.com/raxysstudios/andax'),
        ),
      ],
      icon: const RaxysLogo(
        opacity: .1,
        scale: 7,
      ),
    );
  }
}
