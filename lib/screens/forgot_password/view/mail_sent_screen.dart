import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/widgets/buttons/custom_button.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class MailSentScreen extends StatefulWidget {
  const MailSentScreen({Key? key}) : super(key: key);

  @override
  State<MailSentScreen> createState() => _MailSentScreenState();
}

class _MailSentScreenState extends State<MailSentScreen> {
  @override
  void initState() {
    // Future.delayed(const Duration(seconds: 4), () {
    //   if (mounted) Navigator.of(context).pop();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/animation/mail_sent_animation.json',
              repeat: false,
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 70.w,
                child: Text(
                  LocaliazationKey.password_reset_link_sent.tr(),
                  style: AppStyles.textStyle4(
                      context: context, size: 16, isBold: false),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: SizedBox(
                width: 40.w,
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  title: LocaliazationKey.done.tr(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
