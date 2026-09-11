import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/card_types_screen/controller/card_type_provider.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/cards/alert_status_card.dart';
import '../../../widgets/cards/vehicle_status_card.dart';

class CardTypesScreen extends StatefulWidget {
  const CardTypesScreen({super.key});

  @override
  State<CardTypesScreen> createState() => _CardTypesScreenState();
}

class _CardTypesScreenState extends State<CardTypesScreen> {
  // final vehicleStatusCardsList = [
  //   CardTypeModel(cardTypeId: 1),
  //   CardTypeModel(cardTypeId: 2),
  //   CardTypeModel(cardTypeId: 3),
  //   CardTypeModel(cardTypeId: 4),
  //   CardTypeModel(cardTypeId: 5),
  //   CardTypeModel(cardTypeId: 6),
  // ];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await AppHelper.getHiveBoxData();
      CardTypeProvider cardTypeProvider =
          // ignore: use_build_context_synchronously
          Provider.of<CardTypeProvider>(context, listen: false);
      cardTypeProvider
        ..setCurrentVehicleStatusCard()
        ..setCurrentAlertStatusCard;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cardTypeProvider = Provider.of<CardTypeProvider>(context);
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.choose_cards.tr(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 85.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaliazationKey.vehicle_status_card.tr(),
                    style: AppStyles.textStyle4(context: context, isBold: true),
                  ),
                  2.h.height,
                  Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            for (int index = 0;
                                index <
                                    cardTypeProvider
                                        .vehicleStatusCardsList.length;
                                index++)
                              // i.isEven && i < displayList!.length - 1
                              //     ?
                              SizedBox(
                                width: (index.isEven &&
                                        index ==
                                            cardTypeProvider
                                                    .vehicleStatusCardsList
                                                    .length -
                                                1)
                                    ? 82.w
                                    : 42.w,
                                // 18.h,

                                child: GestureDetector(
                                    onTap: () {
                                      cardTypeProvider.selectVehicleStatusCard(
                                          cardTypeId: cardTypeProvider
                                              .vehicleStatusCardsList[index]
                                              .cardTypeId);
                                      // cardTypeProvider.vehicleStatusCardsList[index].isSelected =
                                      //     !cardTypeProvider.vehicleStatusCardsList[index]
                                      //         .isSelected;
                                      // setState(() {});
                                    },
                                    child: VehicleStatusCard(
                                      count: '12',
                                      icon: AppHelper.returnIcons(
                                          title: 'Moving'),
                                      title: AppHelper.returnJapaneseText(
                                        title: 'Moving',
                                      ),
                                      iconColor: AppHelper.returnIconColor(
                                          title: 'Moving'),
                                      cardType: cardTypeProvider
                                          .vehicleStatusCardsList[index]
                                          .cardTypeId!,
                                      isSlelected: cardTypeProvider
                                          .vehicleStatusCardsList[index]
                                          .isSelected!,
                                      enableBorder: true,
                                    )),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  3.h.height,
                  Text(
                    LocaliazationKey.alert_status_card.tr(),
                    style: AppStyles.textStyle4(context: context, isBold: true),
                  ),
                  2.h.height,
                  Wrap(
                    spacing: 9.w,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: [
                      for (int i = 0;
                          i < cardTypeProvider.alertStatusCardsList.length;
                          i++)
                        Padding(
                          padding: EdgeInsets.only(left: 2.w),
                          child: InkWell(
                            onTap: () {
                              cardTypeProvider.selectAlertStatusCard(
                                  cardTypeId: cardTypeProvider
                                      .alertStatusCardsList[i].cardTypeId);
                            },
                            child: AlertStatusCard(
                              alertCount: 43,
                              alertType: LocaliazationKey.sharp_turn.tr(),
                              isSelected: cardTypeProvider
                                  .alertStatusCardsList[i].isSelected!,
                              cardType: cardTypeProvider
                                  .alertStatusCardsList[i].cardTypeId!,
                            ),
                          ),
                        )
                    ],
                  ),
                  const Spacer(),
                  CustomButton(
                    onPressed: () async {
                      await Global.box.put(
                          vehicleStatusCardTypeIdKey,
                          cardTypeProvider
                              .currentSelectedVehicleStatusCard!.cardTypeId!);
                      await Global.box.put(
                          alertStatusCardTypeIdKey,
                          cardTypeProvider
                              .currentSelectedAlertStatusCard!.cardTypeId!);
                      await AppHelper.getHiveBoxData();
                      customToast(
                        message: LocaliazationKey.card_settings_updated.tr(),
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    title: LocaliazationKey.apply.tr(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardTypeModel {
  final int? cardTypeId;
  bool isSelected;

  CardTypeModel({required this.cardTypeId, this.isSelected = false});
}
