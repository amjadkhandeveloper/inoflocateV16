import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_colors.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget(
      {super.key,
      this.isLoading = false,
      required this.controller,
      this.onChanged,
      this.onPressedClear});

  final void Function()? onPressedClear;
  final bool isLoading;
  final Function(String)? onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : AppColors.grey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : AppColors.grey),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: const Icon(Icons.search),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: TextField(
                  controller: controller,
                  inputFormatters: [
                    // NoLeadingSpaceFormatter(),
                    FilteringTextInputFormatter.deny(RegExp('^\\s')),
                  ],
                  decoration: InputDecoration(
                      isDense: true,
                      hintText: LocaliazationKey.search.tr(),
                      border: InputBorder.none),
                  onChanged: onChanged),
            ),
            controller.text.isEmpty
                ? Container()
                : IconButton(
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 25, child: CircularProgressIndicator())
                        : const Icon(Icons.cancel),
                    onPressed: isLoading ? null : onPressedClear),
          ],
        )

        //  ListTile(
        //   leading: const Icon(Icons.search),
        //   title: TextField(
        //       controller: controller,
        //       inputFormatters: [NoLeadingSpaceFormatter()],
        //       decoration: InputDecoration(
        //           isDense: true,
        //           hintText: LocaliazationKey.search.tr(),
        //           border: InputBorder.none),
        //       onChanged: onChanged),
        //   trailing: controller.text.isEmpty
        //       ? null
        //       : IconButton(
        //           icon: isLoading
        //               ? const SizedBox.square(
        //                   dimension: 25, child: CircularProgressIndicator())
        //               : const Icon(Icons.cancel),
        //           onPressed: isLoading ? null : onPressedClear),
        // ),
        );
  }
}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }
    if (newValue.text.endsWith(' ')) {
      final String trimedText = newValue.text.trimRight();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}
