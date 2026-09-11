import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/login/controller/client_provider.dart';
import 'package:infolocate/screens/login/model/user_login_request_model.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/powered_by_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_localization_key.dart';
import '../../../utils/enums.dart';

/// Tenant (client) login — first auth step after language selection.
class ClientLoginScreen extends StatefulWidget {
  static String routeName = '/clientLoginRoute';
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final TextEditingController clientNameCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  bool isPasswordObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    clientNameCtl.dispose();
    passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientLoginProvider>(context);
    final loading = clientState.state == NotifierState.loading;

    return AppAuthScaffold(
      title: LocaliazationKey.client_login.tr(),
      subtitle: 'Client access',
      footer: const PoweredByTextWidget(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaliazationKey.user_name.tr(),
                style: AppUi.fieldLabel(context)),
            const SizedBox(height: 8),
            TextFormField(
              controller: clientNameCtl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                LengthLimitingTextInputFormatter(48),
                FilteringTextInputFormatter.deny(RegExp(r' ')),
              ],
              decoration: AppUi.inputDecoration(
                context: context,
                hintText: LocaliazationKey.user_name.tr(),
                prefixIcon: Icon(Icons.person_outline_rounded,
                    size: 20, color: AppUi.muted(context)),
              ),
              validator: (name) => AppHelper.uerNameValidator(name),
            ),
            const SizedBox(height: 16),
            Text(LocaliazationKey.password.tr(),
                style: AppUi.fieldLabel(context)),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordCtl,
              obscureText: isPasswordObscure,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                LengthLimitingTextInputFormatter(32),
                FilteringTextInputFormatter.deny(RegExp(r' ')),
              ],
              decoration: AppUi.inputDecoration(
                context: context,
                hintText: LocaliazationKey.password.tr(),
                prefixIcon: Icon(Icons.lock_outline_rounded,
                    size: 20, color: AppUi.muted(context)),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordObscure = !isPasswordObscure;
                    });
                  },
                  icon: Icon(
                    isPasswordObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppUi.muted(context),
                  ),
                ),
              ),
              validator: (value) => AppHelper.passwordValidator(value),
            ),
            const SizedBox(height: 24),
            AppUi.primaryButton(
              title: LocaliazationKey.login.tr(),
              loading: loading,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  await clientState.clientLogin(
                    loginRequestdata: UserLoginRequestModel(
                        loginName: clientNameCtl.text.trim(),
                        loginPwd: passwordCtl.text.trim()),
                  );
                  if (!mounted) return;
                  if (clientState.state == NotifierState.loaded &&
                      clientState.authData != null) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        UserLoginScreen.routeName, (route) => false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
