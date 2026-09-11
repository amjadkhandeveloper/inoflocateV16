import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';

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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('^\\s')),
      ],
      style: AppUi.body(context),
      decoration: AppUi.inputDecoration(
        context: context,
        hintText: LocaliazationKey.search.tr(),
        prefixIcon: Icon(Icons.search_rounded,
            size: 20, color: AppUi.muted(context)),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppUi.accent,
                        ),
                      )
                    : Icon(Icons.close_rounded,
                        size: 18, color: AppUi.muted(context)),
                onPressed: isLoading ? null : onPressedClear,
              ),
      ),
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
