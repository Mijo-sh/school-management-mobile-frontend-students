import '../../../../../core/assets_manager/images_manager.dart';
import '../../../../../core/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class HelpUsPage extends StatelessWidget {
  const HelpUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context)
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.help),
          const SizedBox(width: 15),
          Text("drawer_help_us".tr(context))
        ]
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              "help_us_message".tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _launchTelegram,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary
              ),
              child: Text("help_us_button".tr(context))
            ),
            SizedBox(height: 30),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primary, width: 4),
                image: const DecorationImage(
                  image: AssetImage(ImagesManager.QRCode),
                  fit: BoxFit.cover
                )
              )
            )
          ]
        )
      )
    );
  }

  void _launchTelegram() async {
    final Uri uri = Uri.parse("https://t.me/mijoschool_support_bot");
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}