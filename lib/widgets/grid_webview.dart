import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:infolocate/utils/app_lifecycle.dart';
import 'package:infolocate/utils/orientation_helper.dart';
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
  bool loadingWebView = true;
  List<InAppWebViewController?> webControllers = [];

  @override
  void initState() {
    super.initState();
    AppLifecycleTracker.instance.beginSuppressBackgroundRefresh();
    OrientationHelper.lockPortrait();
    for (int i = 1; i <= (widget.url?.length ?? 0); i++) {
      InAppWebViewController? webCtl;
      webControllers.add(webCtl);
    }
  }

  @override
  void dispose() {
    AppLifecycleTracker.instance.endSuppressBackgroundRefresh();
    OrientationHelper.lockPortrait();
    super.dispose();
  }

  Future<void> _toggleRotation(Orientation orientation) async {
    await OrientationHelper.toggle(orientation == Orientation.landscape);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() {});
  }

  GridConfigurationModel getGridConfiguration(
      {required Orientation orientation}) {
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

    return GridConfigurationModel(
        aspectRation: aspectRation, crossAxisCount: crossAxisCount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title ?? ''),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'Rotate',
                  onPressed: () => _toggleRotation(orientation),
                  icon: const Icon(Icons.screen_rotation_alt_outlined),
                ),
              ],
            ),
            body: widget.url != null
                ? widget.url!.length == 1
                    ? _gridItem(context, 0, orientation)
                    : GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getGridConfiguration(
                                  orientation: orientation)
                              .crossAxisCount!,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: getGridConfiguration(
                                  orientation: orientation)
                              .aspectRation!,
                        ),
                        itemCount: widget.url!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _gridItem(context, index, orientation);
                        },
                      )
                : const SizedBox.shrink(),
          );
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
                ),
              );
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
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
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
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}

class GridConfigurationModel {
  final int? crossAxisCount;
  final double? aspectRation;

  GridConfigurationModel(
      {required this.crossAxisCount, required this.aspectRation});
}
