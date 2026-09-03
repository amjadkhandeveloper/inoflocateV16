import 'package:flutter/material.dart';

import '../utils/app_styles.dart';

class CustomChoiceChip extends StatelessWidget {
  const CustomChoiceChip(
      {super.key,
      this.title,
      this.selected = false,
      this.onSelected,
      this.focusNode});
  final String? title;
  final bool selected;
  final FocusNode? focusNode;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        focusNode: focusNode,
        label: Text(
          title ?? '',
          style: AppStyles.textStyle5(context: context),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        selected: selected,
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8)),
        onSelected: onSelected,
        disabledColor: Colors.transparent,
        selectedColor: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
      ),
    );
  }
}
