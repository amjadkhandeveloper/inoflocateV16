import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.url,
    this.title,
    this.orientationMode = Orientation.portrait,
    this.isGridView = false,
  });

  final String? url;
  final String? title;
  final Orientation orientationMode;
  final bool isGridView;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool loadingWebView = true;
  late InAppWebViewController webController;

  // bool isFullScreenMode = false;
  @override
  void initState() {
    if (widget.isGridView) {
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft],
      );
    }

    super.initState();
  }

  // @override
  // void dispose() {
  //   if (widget.makePortraitOnBackPressed) {
  //     SystemChrome.setPreferredOrientations(
  //       [DeviceOrientation.portraitUp],
  //     );
  //   }
  //   super.dispose();
  // }

  @override
  void dispose() {
    if (widget.orientationMode == Orientation.landscape) {
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft],
      );
    } else {
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log(isFullScreenMode.toString());
    // inspect(widget.url.toString());
    return SafeArea(
      child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
        return Scaffold(
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
                    // await webController.reload();
                    setState(() {});
                  },
                  icon: const Icon(Icons.screen_rotation_alt_outlined))
            ],
          ),
          body: Stack(
            children: [
              InAppWebView(
                onLoadStop: (controller, url) {
                  setState(() {
                    loadingWebView = false;
                    webController = controller;
                  });
                },
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.url ?? ''),
                ),
                onReceivedServerTrustAuthRequest: (controller, challenge) async {
                  return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  );
                },
              )
              //   onReceivedServerTrustAuthRequest:
              //       (controller, challenge) async {
              //     //Do some checks here to decide if CANCELS or PROCEEDS
              //     return ServerTrustAuthResponse(
              //         action: ServerTrustAuthResponseAction.PROCEED);
              //   },
              //   // onEnterFullscreen: (controller) async {
              //   //   // await controller.zoomBy(zoomFactor: 10);
              //   //   // await controller.goBack();
              //   //   // await controller.canGoBack();
              //   //   isFullScreenMode = true;
              //   //   setState(() {});
              //   // },
              //   // onExitFullscreen: (controller) => setState(() {
              //   //   isFullScreenMode = false;
              //   // }),
              // ),
              // if (loadingWebView) CustomShimmerEffect(child: Container()),
              // Positioned(
              //   // top: 5,
              //   child: isFullScreenMode
              //       ? Card(
              //           child: IconButton(
              //               onPressed: () {
              //                 Navigator.pop(context);
              //               },
              //               icon: const Icon(Icons.arrow_back)),
              //         )
              //       : Container(),
              // )
            ],
          ),
        );
      }),
    );
  }
}
