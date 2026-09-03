// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/forgot_password/controller/forgot_password_provider.dart';
import 'package:infolocate/screens/forgot_password/model/forgot_password_request_model.dart';
import 'package:infolocate/screens/forgot_password/view/mail_sent_screen.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isForgotPassword;
  const ForgotPasswordScreen({
    Key? key,
    required this.isForgotPassword,
  }) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = Provider.of<ForgotPasswordProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isForgotPassword
              ? LocaliazationKey.forgot_password.tr()
              : LocaliazationKey.reset_password.tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaliazationKey.user_name.tr(),
                  style: AppStyles.textStyle4(
                      context: context, size: 16, isBold: true),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  controller: usernameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r' '))
                  ],
                  decoration: AppStyles.inputFieldStyle(
                      hintText: LocaliazationKey.please_enter_username.tr()),
                  validator: (name) => AppHelper.uerNameValidator(name),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LocaliazationKey.email_note.tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                forgotPasswordState.state == NotifierState.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : CustomButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (Global.savedUserAuthData != null &&
                                usernameController.text !=
                                    Global.savedUserAuthData!.username!) {
                              return customToast(
                                message:
                                    LocaliazationKey.incorrect_username.tr(),
                              );
                            } else {
                              FocusScope.of(context).unfocus();
                              await forgotPasswordState.forgotPassword(
                                forgotPasswordRequestModel:
                                    ForgotPasswordRequestModel(
                                        loginName:
                                            usernameController.text.trim()),
                              );
                              if (forgotPasswordState.state ==
                                      NotifierState.loaded &&
                                  forgotPasswordState
                                          .forgotPasswordResponseModel !=
                                      null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MailSentScreen(),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        title: LocaliazationKey.confirm.tr(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
