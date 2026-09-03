import 'package:flutter/material.dart';

class LanguageSelectWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final bool isEnglish;
  final TextTheme textTheme;

  final bool isFirstItem;
  final bool isLastItem;

  // final String? imageUrl;
  const LanguageSelectWidget({
    super.key,
    required this.textTheme,
    required this.title,
    required this.subTitle,
    required this.isEnglish,
    this.isFirstItem = false,
    this.isLastItem = false,
    // required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      // height: 10.h,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(isFirstItem ? 8 : 0),
            topLeft: Radius.circular(isFirstItem ? 8 : 0),
            bottomLeft: Radius.circular(isLastItem ? 8 : 0),
            bottomRight: Radius.circular(isLastItem ? 8 : 0)),
        // color: Color(0xffE7F3FF),
        color: isEnglish
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Theme.of(context).cardColor,
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).brightness == Brightness.dark
        //         ? Colors.black26
        //         : Colors.grey.withOpacity(0.2),
        //     spreadRadius: 5,
        //     blurRadius: 10,
        //     offset: const Offset(0, 3), // changes position of shadow
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title!,
                      style: textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 4, top: 8),
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            top: 4,
                          ),
                          child: Text(subTitle!, style: textTheme.titleSmall),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            isEnglish
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: SizedBox(
                        height: 20,
                        child: Icon(
                          Icons.check_circle,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
