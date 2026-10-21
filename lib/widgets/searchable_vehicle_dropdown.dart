import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:sizer/sizer.dart';

/// Searchable vehicle picker for large lists (track history, video playback).
class SearchableVehicleDropdown<T> extends StatelessWidget {
  const SearchableVehicleDropdown({
    super.key,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.selectedItem,
    this.compareFn,
    this.filterFn,
    this.disabledItemFn,
    this.itemBuilder,
    this.hintText,
  });

  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final bool Function(T, T)? compareFn;
  final bool Function(T, String)? filterFn;
  final bool Function(T)? disabledItemFn;
  final Widget Function(BuildContext, T, bool)? itemBuilder;
  final String? hintText;

  bool _defaultFilter(T item, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return itemAsString(item).toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppUi.cardColor(context),
        border: Border.all(color: AppUi.line(context)),
        borderRadius: BorderRadius.circular(AppUi.radiusSm),
      ),
      child: DropdownSearch<T>(
        items: items,
        selectedItem: selectedItem,
        itemAsString: itemAsString,
        compareFn: compareFn ?? (a, b) => itemAsString(a) == itemAsString(b),
        filterFn: filterFn ?? _defaultFilter,
        onChanged: onChanged,
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: AppUi.body(context).copyWith(fontSize: 16),
          dropdownSearchDecoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            hintText: hintText ?? LocaliazationKey.select.tr(),
            hintStyle: AppUi.mutedStyle(context),
            prefixIcon: Icon(
              Icons.directions_car_outlined,
              color: AppUi.muted(context),
            ),
          ),
        ),
        popupProps: PopupProps.modalBottomSheet(
          showSearchBox: true,
          showSelectedItems: true,
          constraints: BoxConstraints(maxHeight: 70.h),
          searchDelay: const Duration(milliseconds: 150),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              LocaliazationKey.search.tr(),
              style: AppUi.body(context).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          searchFieldProps: TextFieldProps(
            autofocus: true,
            style: AppUi.body(context),
            decoration: AppUi.inputDecoration(
              context: context,
              hintText: LocaliazationKey.search.tr(),
              prefixIcon: Icon(Icons.search, color: AppUi.muted(context)),
            ),
          ),
          emptyBuilder: (context, searchEntry) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                LocaliazationKey.no_matching_records_found.tr(),
                style: AppUi.mutedStyle(context),
              ),
            ),
          ),
          itemBuilder: itemBuilder ??
              (context, item, isSelected) {
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  title: Text(
                    itemAsString(item),
                    style: AppUi.body(context).copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: AppUi.accent)
                      : null,
                );
              },
          disabledItemFn: disabledItemFn,
        ),
      ),
    );
  }
}
