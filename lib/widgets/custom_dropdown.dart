import 'package:flutter/material.dart';

import '../utils/app_styles.dart';

class CustomDropDownButton extends StatelessWidget {
  const CustomDropDownButton(
      {super.key, this.items, this.icon, required this.onChanged, this.value});
  final List<String?>? items;
  final Widget? icon;
  final String? value;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final menuItems =
        (items ?? []).where((e) => e != null && e.isNotEmpty).toList();
    final initial =
        (value != null && menuItems.contains(value)) ? value : null;
    return PopupMenuButton<String?>(
        icon: icon,
        tooltip: 'Open Filter',
        onSelected: onChanged,
        initialValue: initial,
        itemBuilder: (BuildContext context) {
          return menuItems
              .map((String? itemValue) => PopupMenuItem<String?>(
                    value: itemValue,
                    child: Text(
                      itemValue!,
                      style: AppStyles.textStyle5(context: context),
                    ),
                  ))
              .toList();
          // Constants.choices.map((String choice) {
          //   return PopupMenuItem<String>(
          //     value: choice,
          //     child: Text(choice),
          //   );
          // }).toList();
        });
    // return DropdownButton<String?>(
    //   value: value,
    //   underline: Container(),
    //   // hint: Text('selected dat'),
    // items: items!
    //     .map((String? value) => DropdownMenuItem<String?>(
    //           value: value,
    //           alignment: Alignment.center,
    //           child: Text(
    //             value!,
    //             style: AppStyles.textStyle5(context: context),
    //           ),
    //         ))
    //     .toList(),
    //   icon: icon,
    //   onChanged: onChanged,
    // );
  }
}
