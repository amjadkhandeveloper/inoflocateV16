import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:lottie/lottie.dart';

class MailSentScreen extends StatefulWidget {
  const MailSentScreen({Key? key}) : super(key: key);

  @override
  State<MailSentScreen> createState() => _MailSentScreenState();
}

class _MailSentScreenState extends State<MailSentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppUi.card(
              context: context,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LottieBuilder.asset(
                    'assets/animation/mail_sent_animation.json',
                    repeat: false,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocaliazationKey.password_reset_link_sent.tr(),
                    style: AppUi.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppUi.primaryButton(
                    title: LocaliazationKey.done.tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
