import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/screens/forgot_password/view/forgot_password_screen.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/widgets/path_clippers/login_bottom_clip.dart';
import 'package:infolocate/widgets/path_clippers/login_top_clip.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../animation/custom_fade_animation.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';
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
  final TextEditingController? userNameCtl = TextEditingController();
  final TextEditingController? passwordCtl = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  bool isPasswordObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameCtl!.dispose();
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
                      flex: 4,
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
    final userState = Provider.of<UserProvider>(context);
    return Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              LocaliazationKey.user_login.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextFormField(
            controller: userNameCtl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              LengthLimitingTextInputFormatter(48),
              FilteringTextInputFormatter.deny(RegExp(r' '))
            ],
            decoration: AppStyles.inputFieldStyle(
                hintText: LocaliazationKey.user_name.tr()),
            validator: (name) => AppHelper.uerNameValidator(name),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
          ),
          // SizedBox(
          //   height: 3.h,
          // ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                focusNode: passwordFocusNode,
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
              const SizedBox(
                height: 14,
              ),
              GestureDetector(
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
          userState.state == NotifierState.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CustomButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (key.currentState!.validate()) {
                      if (Global.savedClientAuthData == null) {
                        await AppHelper.getHiveBoxData();
                      }
                      await userState.userLogin(
                        loginRequestdata: UserLoginRequestModel(
                            url: Global.savedClientAuthData!.clientUrl,
                            loginName: userNameCtl!.text.trim(),
                            loginPwd: passwordCtl!.text.trim()),
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
                  title: LocaliazationKey.login.tr(),
                ),

          // SizedBox(
          //   height: 4.h,
          // ),
          Visibility(
            visible: userState.state != NotifierState.loading,
            child: CustomButton(
                icon: Icons.arrow_back,
                textColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : null,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientLoginScreen()),
                      (route) => false);
                },
                // textColor: Colors.black,
                title: LocaliazationKey.switch_to_client_login.tr(),
                buttonColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .toMaterial()!
                    .shade100),
          ),
          // SizedBox(
          //   height: 5.h,
          // ),
        ],
      ),
    );
  }
}
