// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/forgot_password/controller/forgot_password_provider.dart';
import 'package:infolocate/screens/forgot_password/model/forgot_password_request_model.dart';
import 'package:infolocate/screens/forgot_password/view/mail_sent_screen.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/enums.dart';

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
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = Provider.of<ForgotPasswordProvider>(context);
    final loading = forgotPasswordState.state == NotifierState.loading;
    final title = widget.isForgotPassword
        ? LocaliazationKey.forgot_password.tr()
        : LocaliazationKey.reset_password.tr();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppUi.pageBg(context),
        body: SafeArea(
          child: Column(
            children: [
              AppUi.pageHeader(
                context: context,
                title: title,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: AppUi.card(
                      context: context,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaliazationKey.user_name.tr(),
                            style: AppUi.fieldLabel(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: usernameController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r' ')),
                            ],
                            decoration: AppUi.inputDecoration(
                              context: context,
                              hintText: LocaliazationKey.please_enter_username
                                  .tr(),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                                color: AppUi.muted(context),
                              ),
                            ),
                            validator: (name) =>
                                AppHelper.uerNameValidator(name),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            LocaliazationKey.email_note.tr(),
                            style: AppUi.mutedStyle(context),
                          ),
                          const SizedBox(height: 24),
                          AppUi.primaryButton(
                            title: LocaliazationKey.confirm.tr(),
                            loading: loading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (Global.savedUserAuthData != null &&
                                    usernameController.text !=
                                        Global.savedUserAuthData!.username!) {
                                  return customToast(
                                    message: LocaliazationKey
                                        .incorrect_username
                                        .tr(),
                                  );
                                } else {
                                  FocusScope.of(context).unfocus();
                                  await forgotPasswordState.forgotPassword(
                                    forgotPasswordRequestModel:
                                        ForgotPasswordRequestModel(
                                            loginName: usernameController.text
                                                .trim()),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
