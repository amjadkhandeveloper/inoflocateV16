import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:infolocate/widgets/custom_webview.dart';
import 'package:shimmer/shimmer.dart';

class GridVideoPlayerScreen extends StatefulWidget {
  const GridVideoPlayerScreen({
    super.key,
    this.url,
    this.title,
  });

  final List<String?>? url;
  final String? title;

  @override
  State<GridVideoPlayerScreen> createState() => _GridVideoPlayerScreenState();
}

class _GridVideoPlayerScreenState extends State<GridVideoPlayerScreen> {
  // late InAppWebViewController webController;
  bool loadingWebView = true;

  List<InAppWebViewController?> webControllers = [];

  @override
  void initState() {
    for (int i = 1; i <= widget.url!.length; i++) {
      InAppWebViewController? webCtl;
      webControllers.add(webCtl);
    }
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
    super.dispose();
  }

  GridConfigurationModel getGridConfiguration({required Orientation orientation}) {
    final size = widget.url!.length;
    int crossAxisCount;
    double aspectRation;
    if (orientation == Orientation.landscape) {
      crossAxisCount = 3;
      aspectRation = 12 / 9;
      if (size > 6) {
        crossAxisCount = 3;
        aspectRation = 12 / 4.8;
      } else if (size > 4 && size <= 6) {
        crossAxisCount = 3;
        aspectRation = 12 / 6.9;
      } else if (size > 2 && size <= 4) {
        crossAxisCount = 2;
        aspectRation = 12 / 4.6;
      } else if (size > 0 && size <= 2) {
        crossAxisCount = 2;
        aspectRation = 12 / 9.2;
      } else {
        crossAxisCount = 3;
        aspectRation = 12 / 9;
      }
    } else {
      crossAxisCount = 1;
      aspectRation = 12 / 12;
      if (size > 6) {
        crossAxisCount = 2;
        aspectRation = 12 / 10.9;
      } else if (size > 4 && size <= 6) {
        crossAxisCount = 1;
        aspectRation = 12 / 3.6;
      } else if (size > 2 && size <= 4) {
        crossAxisCount = 1;
        aspectRation = 12 / 5.6;
      } else if (size > 0 && size <= 2) {
        crossAxisCount = 1;
        aspectRation = 12 / 10.8;
      } else if (size > 0 && size == 1) {
        crossAxisCount = 1;
        aspectRation = 1;
      } else {
        crossAxisCount = 1;
        aspectRation = 12 / 12;
      }
    }

    return GridConfigurationModel(aspectRation: aspectRation, crossAxisCount: crossAxisCount);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return SafeArea(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Scaffold(
            // floatingActionButton: FloatingActionButton(onPressed: () {
            //   widget.url!.removeAt(widget.url!.length - 1);
            //   setState(() {});
            // }),
              appBar: AppBar(
                title: Text(widget.title ?? ''),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () async {
                        if (orientation == Orientation.landscape) {
                          SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.portraitUp],
                          );
                        } else {
                          SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.landscapeLeft],
                          );
                        }
                        await Future.delayed(const Duration(milliseconds: 300));
                        // webControllers.forEach(
                        //   (element) async {
                        //     await element!.reload();
                        //   },
                        // );
                        // await webController.reload();
                        setState(() {});
                      },
                      icon: const Icon(Icons.screen_rotation_alt_outlined))
                ],
              ),
              body: widget.url != null
                  ? widget.url!.length == 1
                  ? _gridItem(context, 0, orientation)
                  : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      getGridConfiguration(orientation: orientation).crossAxisCount!,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio:
                      getGridConfiguration(orientation: orientation).aspectRation!),
                  itemCount: widget.url!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _gridItem(context, index, orientation);
                  })
              // orientation == Orientation.landscape
              //     ?
              // Padding(
              //     padding: const EdgeInsets.only(left: 8.0),
              //     child: Wrap(
              //       runAlignment: WrapAlignment.center,
              //       spacing: 2.w,
              //       runSpacing: 2.w,
              //       children: [
              //         ...List.generate(
              //             widget.url!.length,
              //             (index) => SizedBox(
              //                 height: 11.8.h,
              //                 width: 60.w,
              //                 child: _gridItem(context, index))
              //             // Padding(
              //             //       padding: const EdgeInsets.all(8.0),
              //             //       child: Container(
              //             //           height: 100,
              //             //           // width: 100,
              //             //           color: Colors.green),
              //             //     )
              //             )
              //       ],
              //     ),
              //   )
              // : Container()

              //  GridView.builder(
              //     itemCount: widget.url!.length,
              //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         childAspectRatio: 12 / 5,
              //         crossAxisCount: 2,
              //         crossAxisSpacing: 2.w,
              //         mainAxisSpacing: 2.w),
              //     itemBuilder: (context, index) => _gridItem(context, index),
              //   )
                  : Container());
        },
      ),
    );
  }

  Stack _gridItem(
      BuildContext context,
      int index,
      Orientation orientation,
      ) {
    return Stack(
      children: [
        SizedBox(
          // height: orientation == Orientation.landscape ? 20.h : null,
          child: InkWell(
            onDoubleTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      title: widget.title,
                      url: widget.url![index],
                      orientationMode: orientation,
                      isGridView: true,
                    ),
                  ));
            },
            child: InAppWebView(
              onLoadStop: (controller, url) {
                setState(() {
                  loadingWebView = false;
                  webControllers[index] = controller;
                });
              },
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url![index] ?? ''),
              ),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                webControllers[index] = controller;
                //Do some checks here to decide if CANCELS or PROCEEDS
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          ),
        ),
        if (loadingWebView)
          Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Theme.of(context).cardColor,
              highlightColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade100
                  : Colors.grey.shade500,
              child: Container(
                // width: 300,
                // height: 400,
                color: Colors.green,
              ))
      ],
    );
  }
}

class GridConfigurationModel {
  final int? crossAxisCount;
  final double? aspectRation;

  GridConfigurationModel({required this.crossAxisCount, required this.aspectRation});
}
