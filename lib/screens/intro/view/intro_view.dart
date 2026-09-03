import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/utils/app_colors.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:sizer/sizer.dart';

import '../../../animation/custom_fade_animation.dart';
import '../../../utils/app_localization_key.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../model/intro_model.dart';

class IntroScreen extends StatefulWidget {
  static String routeName = '/introRoute';
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController? _pageController;
  int currentIndex = 0;

  final _slideImages = [
    IntroImageModel(
      image: "assets/images/intro_one.png",
      title: LocaliazationKey.insights.tr(),
      content: LocaliazationKey.intro_page_one.tr(),
    ),
    IntroImageModel(
      image: "assets/images/intro_two.png",
      title: LocaliazationKey.live_video.tr(),
      content: LocaliazationKey.intro_page_two.tr(),
    ),
    IntroImageModel(
      image: "assets/images/intro_three.png",
      title: LocaliazationKey.live_tracking.tr(),
      content: LocaliazationKey.intro_page_three.tr(),
    ),
    IntroImageModel(
      image: "assets/images/intro_four.png",
      title: LocaliazationKey.alerts.tr(),
      content: "${LocaliazationKey.live_tracking.tr()}...",
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);

    super.initState();
  }

  @override
  void dispose() {
    _pageController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  ClientLoginScreen.routeName, (route) => false);
            },
            child: Row(
              children: [
                Text(
                  LocaliazationKey.skip.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: AppColors.customGrey),
                ),
                const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.customGrey,
                )
              ],
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: <Widget>[
              ...List.generate(
                  _slideImages.length,
                  (index) => makePage(
                      image: Image.asset(
                        _slideImages[index].image.toString(),
                        fit: BoxFit.cover,
                      ),
                      // SvgPicture.asset(
                      //   _slideImages[index].image.toString(),
                      //   fit: BoxFit.cover,
                      //   height: 47.h,
                      //   colorFilter: ColorFilter.mode(
                      //       Theme.of(context).colorScheme.primary,
                      //       BlendMode.dstIn
                      //       // BlendMode.srcIn
                      //       ),
                      // ),
                      // Image.asset(_slideImages[index].image.toString()),
                      title: _slideImages[index].title,
                      isLast: currentIndex == _slideImages.length - 1,
                      content: _slideImages[index].content))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Widget makePage({Widget? image, title, content, isLast}) {
    return CustomFadeScaleTransition(
      child: Padding(
        padding: EdgeInsets.only(top: 3.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: image ?? Container(),
                  ),
                  6.h.height
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 50, right: 50,
                  // bottom: 10.h
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          // color: AppColors.grey,
                          fontSize: 19,
                          fontWeight: FontWeight.w500),
                    ),
                    if (isLast)
                      Padding(
                          padding: EdgeInsets.only(bottom: 10.h, top: 3.h),
                          child: CustomButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClientLoginScreen(),
                                  ),
                                  (route) => false);
                            },
                            title: LocaliazationKey.get_started.tr(),
                          ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 30 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : null,
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(5)),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _slideImages.length; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }
}
