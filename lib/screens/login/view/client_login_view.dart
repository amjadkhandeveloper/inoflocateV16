import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/login/controller/client_provider.dart';
import 'package:infolocate/screens/login/model/user_login_request_model.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/widgets/path_clippers/login_bottom_clip.dart';
import 'package:infolocate/widgets/path_clippers/login_top_clip.dart';
import 'package:infolocate/widgets/powered_by_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../animation/custom_fade_animation.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';

/// Tenant (client) login — first auth step after language selection.
class ClientLoginScreen extends StatefulWidget {
  static String routeName = '/clientLoginRoute';
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final TextEditingController? clientNameCtl = TextEditingController();
  final TextEditingController? passwordCtl = TextEditingController();
  bool isPasswordObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    clientNameCtl!.dispose();
    passwordCtl!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        // backgroundColor: Colors.amber,
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: LoginBottomCustomClipper(),
                  child: Container(
                    height: 15.h,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipPath(
                            clipper: LoginTopCustomClipper(),
                            child: Container(
                              height: 35.h,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: CustomFadeScaleTransition(
                              child: Text(
                                'InfoLocate V14',
                                style: AppStyles.infoLocateTextStyle(
                                    context: context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomFadeScaleTransition(
                            child: userForm(context, _formKey)),
                      ),
                    ),
                    const Flexible(
                        fit: FlexFit.tight,
                        child: CustomFadeScaleTransition(
                            child: PoweredByTextWidget()))
                    // SizedBox(height: 4.h,),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Widget userForm(BuildContext context, GlobalKey<FormState> key) {
    final clientState = Provider.of<ClientLoginProvider>(context);
    return Form(
      key: key,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h),
            child: Text(
              LocaliazationKey.client_login.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextFormField(
              controller: clientNameCtl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                LengthLimitingTextInputFormatter(48),
                FilteringTextInputFormatter.deny(RegExp(r' '))
              ],
              decoration: AppStyles.inputFieldStyle(
                  hintText: LocaliazationKey.user_name.tr()),
              validator: (name) => AppHelper.uerNameValidator(name)),
          SizedBox(
            height: 3.h,
          ),
          TextFormField(
            controller: passwordCtl,
            obscureText: isPasswordObscure,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              LengthLimitingTextInputFormatter(32),
              FilteringTextInputFormatter.deny(RegExp(r' '))
            ],
            decoration: AppStyles.inputFieldStyle(
              hintText: LocaliazationKey.password.tr(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordObscure = !isPasswordObscure;
                  });
                },
                icon: Icon(isPasswordObscure
                    ? Icons.visibility_off
                    : Icons.visibility),
              ),
            ),
            validator: (value) => AppHelper.passwordValidator(value),
          ),
          SizedBox(
            height: 3.h,
          ),
          clientState.state == NotifierState.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CustomButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (key.currentState!.validate()) {
                      await clientState.clientLogin(
                        loginRequestdata: UserLoginRequestModel(
                            loginName: clientNameCtl!.text.trim(),
                            loginPwd: passwordCtl!.text.trim()),
                      );
                      if (clientState.state == NotifierState.loaded &&
                          clientState.authData != null) {
                        if (!mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            UserLoginScreen.routeName, (route) => false);
                      }
                    }
                  },
                  title: LocaliazationKey.login.tr(),
                ),
        ],
      ),
    );
  }
}
