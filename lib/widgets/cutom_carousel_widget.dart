import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../screens/dashboard/controller/ads_provider.dart';

class CustomCarouselWidget extends StatefulWidget {
  const CustomCarouselWidget({
    super.key,
  });

  @override
  State<CustomCarouselWidget> createState() => _CustomCarouselWidgetState();
}

class _CustomCarouselWidgetState extends State<CustomCarouselWidget> {
  PageController controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adsState = Provider.of<AdsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            // "${LocaliazationKey.ads_powered_by.tr()} ${Global.savedUserAuthData!.username!}",
            LocaliazationKey.advertisement.tr(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 16),
          ),
        ),
        1.5.h.height,
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 16 / 8,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1200),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: adsState.urlList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.network(
                        i,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: 8,
                    //   right: 4,
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(14),
                    //         bottomLeft: Radius.circular(14),
                    //       ),
                    //     ),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         crossAxisAlignment: CrossAxisAlignment.end,
                    //         children: [
                    //           const Icon(
                    //             Icons.watch_later_outlined,
                    //             color: Colors.black,
                    //             size: 15,
                    //           ),
                    //           const SizedBox(
                    //             width: 6,
                    //           ),
                    //           Text(
                    //             "7 days left",
                    //             style: AppStyles.textStyle5(
                    //               color: Colors.black,
                    //               context: context,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(
          height: 8,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: adsState.urlList.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 6,
              activeDotColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
