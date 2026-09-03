// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// import '../../../utils/app_styles.dart';
// import '../../../widgets/buttons/custom_icon_button.dart';
// import '../../../widgets/cards/custom_card.dart';
// import '../../../widgets/grid_webview.dart';
// import '../../dashboard/model/dashboard_model.dart';

// class AlertCard extends StatelessWidget {
//   final String vehicleNo;
//   final String location;
//   final String trackTime;
//   final String status;
//   final List<String?>? liveUrl;
//   final String? urlTitle;

//   final String? ignition;
//   final String? speed;
//   final String? odometer;
//   final String? idelDuration;
//   final String? stopDuration;
//   final String? engineOffdelay;
//   AlertCard(
//       {super.key,
//       required this.vehicleNo,
//       required this.location,
//       required this.trackTime,
//       required this.status,
//       this.liveUrl,
//       this.urlTitle,
//       this.ignition,
//       this.speed,
//       this.odometer,
//       this.idelDuration,
//       this.stopDuration,
//       this.engineOffdelay});

//   List<Properties> properties = [
//     Properties(name: 'ON', icon: 'assets/icons/Group 107.svg'),
//     Properties(name: '45 kmph', icon: 'assets/icons/Group 148.svg'),
//     Properties(name: '03', icon: 'assets/icons/Group 147.svg'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(top: 3.h),
//       child: Stack(
//         children: [
//           Container(
//             // width: double.infinity,
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//                 border: Border.all(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Theme.of(context).cardColor
//                         : Colors.grey.shade300,
//                     width: 1),
//                 // color: Colors.white,
//                 borderRadius: const BorderRadius.all(Radius.circular(20))),
//             child: Column(
//               children: [
//                 CustomContainer(
//                     applyShawdow: false,
//                     width: double.infinity,
//                     borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 vehicleNo,
//                                 style: AppStyles.textStyle4(
//                                     context: context, isBold: true),
//                               ),
//                               const Spacer(),
//                               Expanded(
//                                 flex: 2,
//                                 child: Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.watch_later_outlined,
//                                       size: 15,
//                                     ),
//                                     SizedBox(
//                                       width: 2.w,
//                                     ),
//                                     Flexible(
//                                       child: Text(
//                                         trackTime,
//                                         style: AppStyles.textStyle5(
//                                           context: context,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 1.h,
//                           ),
//                           Text(
//                             location,
//                             style: AppStyles.textStyle5(context: context),
//                           )
//                         ],
//                       ),
//                     )),
//                 Container(
//                   width: SizerUtil.width,
//                   decoration: BoxDecoration(
//                       // color: Theme.of(context).cardColor,
//                       border: Border.all(
//                           color: Theme.of(context).cardColor, width: 1),
//                       // color: Colors.white,
//                       borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(20),
//                           bottomRight: Radius.circular(20))),
//                   // height: 8.h,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         CustomIconBtn(
//                             onTap: liveUrl == null
//                                 ? null
//                                 : () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           GridVideoPlayerScreen(
//                                               title: vehicleNo, url: liveUrl),
//                                     )),
//                             icon: Icon(
//                               Icons.play_circle,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             //  SvgPicture.asset(
//                             //   colorFilter: ColorFilter.mode(
//                             //       Theme.of(context).colorScheme.primary,
//                             //       BlendMode.srcIn),
//                             //   'assets/icons/Group 107.svg',
//                             //   height: 20,
//                             // ),
//                             title: "PLAY VIDEO"),
//                         CustomIconBtn(
//                             icon: Icon(
//                               Icons.location_on,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             //  SvgPicture.asset(
//                             //   colorFilter: ColorFilter.mode(
//                             //       Theme.of(context).colorScheme.primary,
//                             //       BlendMode.srcIn),
//                             //   'assets/icons/Group 148.svg',
//                             //   height: 20,
//                             // ),
//                             title: "MAP IT"),

//                         CustomIconBtn(
//                             icon: Icon(
//                               Icons.car_crash,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             //  SvgPicture.asset(
//                             //   colorFilter: ColorFilter.mode(
//                             //       Theme.of(context).colorScheme.primary,
//                             //       BlendMode.srcIn),
//                             //   'assets/icons/Group 148.svg',
//                             //   height: 20,
//                             // ),
//                             title: status),
//                         if (ignition != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.games_sharp,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 107.svg',
//                               //   height: 20,
//                               // ),
//                               title: ignition),
//                         if (speed != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.speed,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 148.svg',
//                               //   height: 20,
//                               // ),
//                               title: speed),
//                         if (odometer != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.graphic_eq,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 148.svg',
//                               //   height: 20,
//                               // ),
//                               title: odometer),
//                         if (idelDuration != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.timelapse,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 107.svg',
//                               //   height: 20,
//                               // ),
//                               title: idelDuration),
//                         if (stopDuration != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.stop,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 148.svg',
//                               //   height: 20,
//                               // ),
//                               title: stopDuration),
//                         if (engineOffdelay != null)
//                           CustomIconBtn(
//                               icon: Icon(
//                                 Icons.monitor_heart,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               //  SvgPicture.asset(
//                               //   colorFilter: ColorFilter.mode(
//                               //       Theme.of(context).colorScheme.primary,
//                               //       BlendMode.srcIn),
//                               //   'assets/icons/Group 148.svg',
//                               //   height: 20,
//                               // ),
//                               title: engineOffdelay),

//                         // for (int i = 0; i < properties.length; i++)
//                         //   CustomIconBtn(
//                         //       icon: SvgPicture.asset(
//                         //         colorFilter: ColorFilter.mode(
//                         //             Theme.of(context).colorScheme.primary,
//                         //             BlendMode.srcIn),
//                         //         properties[i].icon!,
//                         //         height: 20,
//                         //       ),
//                         //       title: properties[i].name)
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Positioned(
//           //   right: 5.w,
//           //   top: 3.w,
//           //   child: SvgPicture.asset(
//           //     'assets/icons/Group 264.svg',
//           //     colorFilter: ColorFilter.mode(
//           //         Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//           //     // height: 20,
//           //   ),
//           // Icon(
//           //   // i == 0
//           //   //     ?
//           //   Icons.bookmark,
//           //   // : Icons.bookmark_border_outlined,
//           //   color: Theme.of(context).primaryColor,
//           //   size: 25,
//           // )
//           // )
//         ],
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:sizer/sizer.dart';

// // import '../../../utils/app_styles.dart';
// // import '../../../widgets/buttons/custom_icon_button.dart';
// // import '../../dynamic_status/widget/dynamic_status_card.dart';
// // import '../model/alert_list_response_model.dart';

// // class AlertCard extends StatelessWidget {
// //   const AlertCard({super.key, this.cardData});
// //   final AlertListResponseModelDataAlertdetails? cardData;

// //   @override
// //   Widget build(BuildContext context) {
// //     final buttonList = [
// //       DynamicStatusButtonListModel(
// //           icon: Icons.play_circle, title: 'PLAY VIDEO'),
// //       DynamicStatusButtonListModel(icon: Icons.location_on, title: 'MAP IT'),
// //       DynamicStatusButtonListModel(icon: Icons.car_crash, title: 'HARSH BREAK'),
// //     ];

// //     return Container(
// //       decoration: BoxDecoration(
// //           border: Border.all(color: Colors.grey.shade300, width: 1),
// //           borderRadius: BorderRadius.circular(15)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(10.0),
// //         child: Column(
// //           children: [
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Flexible(
// //                   flex: 4,
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             cardData?.VehicleNo ?? '',
// //                             style: AppStyles.textStyle4(
// //                                 context: context, isBold: true, size: 18),
// //                           ),
// //                           SizedBox(
// //                             height: 1.h,
// //                           ),
// //                           Text(
// //                             cardData!.Location ?? '',
// //                             style: AppStyles.textStyle5(context: context),
// //                           )
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Expanded(
// //                   flex: 3,
// //                   // fit: FlexFit.tight,
// //                   child: Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.watch_later_outlined,
// //                         size: 15,
// //                       ),
// //                       SizedBox(
// //                         width: 2.w,
// //                       ),
// //                       Expanded(
// //                         child: Text(
// //                           cardData!.Alertdatetime ?? '',
// //                           style:
// //                               AppStyles.textStyle4(context: context, size: 10),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               ],
// //             ),
// //             const SizedBox(
// //               height: 5,
// //             ),
// //             FittedBox(
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   ...List.generate(
// //                       buttonList.length,
// //                       (index) => CustomIconBtn(
// //                             icon: Icon(
// //                               buttonList[index].icon,
// //                               color: Theme.of(context).colorScheme.primary,
// //                             ),
// //                             title: buttonList[index].title,
// //                             direction: Axis.horizontal,
// //                           ))
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
