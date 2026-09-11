import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/forgot_password/view/forgot_password_screen.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_helper.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/enums.dart';
import '../../../widgets/powered_by_text_widget.dart';
import '../controller/user_provider.dart';
import '../model/user_login_request_model.dart';

/// User login — second auth step; requires saved client session and [clientUrl].
class UserLoginScreen extends StatefulWidget {
  static String routeName = '/userLoginRoute';
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController userNameCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  bool isPasswordObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameCtl.dispose();
    passwordCtl.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserProvider>(context);
    final loading = userState.state == NotifierState.loading;
    final clientName = Global.savedClientAuthData?.clientName ?? '';

    return AppAuthScaffold(
      title: LocaliazationKey.user_login.tr(),
      subtitle: clientName.isEmpty ? 'User access' : clientName,
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
              controller: userNameCtl,
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
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
            ),
            const SizedBox(height: 16),
            Text(LocaliazationKey.password.tr(),
                style: AppUi.fieldLabel(context)),
            const SizedBox(height: 8),
            TextFormField(
              focusNode: passwordFocusNode,
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(
                        isForgotPassword: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  LocaliazationKey.forgot_password.tr(),
                  style: const TextStyle(
                    color: AppUi.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppUi.primaryButton(
              title: LocaliazationKey.login.tr(),
              loading: loading,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  if (Global.savedClientAuthData == null) {
                    await AppHelper.getHiveBoxData();
                  }
                  await userState.userLogin(
                    loginRequestdata: UserLoginRequestModel(
                        url: Global.savedClientAuthData!.clientUrl,
                        loginName: userNameCtl.text.trim(),
                        loginPwd: passwordCtl.text.trim()),
                  );

                  if (!mounted) return;
                  final loggedIn = userState.authData?.data?.user != null ||
                      Global.savedUserAuthData?.userid != null;
                  if (userState.state == NotifierState.loaded && loggedIn) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.dashboardRoute(), (route) => false);
                  }
                }
              },
            ),
            if (!loading) ...[
              const SizedBox(height: 12),
              AppUi.ghostButton(
                context: context,
                icon: Icons.arrow_back_rounded,
                title: LocaliazationKey.switch_to_client_login.tr(),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientLoginScreen()),
                      (route) => false);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
