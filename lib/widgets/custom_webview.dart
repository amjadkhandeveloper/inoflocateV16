import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

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
  double _progress = 0;
  InAppWebViewController? webController;

  WebUri? get _replayUri {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return null;
    return WebUri(raw, forceToStringRawValue: true);
  }

  @override
  void initState() {
    if (widget.isGridView) {
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft],
      );
    }
    super.initState();
  }

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

  Future<void> _openInSystemBrowser() async {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      customToast(message: 'Invalid playback URL');
      return;
    }
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );
    if (!opened) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final replayUri = _replayUri;
    return SafeArea(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Scaffold(
            backgroundColor: AppUi.pageBg(context),
            appBar: AppUi.appBar(
              context: context,
              title: widget.title ?? 'Video Playback',
              actions: [
                IconButton(
                  tooltip: 'Open in browser',
                  onPressed: _openInSystemBrowser,
                  icon: Icon(Icons.open_in_browser, color: AppUi.ink(context)),
                ),
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
                    setState(() {});
                  },
                  icon: Icon(Icons.screen_rotation_alt_outlined,
                      color: AppUi.ink(context)),
                ),
              ],
            ),
            body: replayUri == null
                ? Center(
                    child: Text(
                      'No playback URL',
                      style: AppUi.mutedStyle(context),
                    ),
                  )
                : Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(url: replayUri),
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          domStorageEnabled: true,
                          databaseEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          mixedContentMode:
                              MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                          useHybridComposition: true,
                          supportZoom: true,
                          iframeAllow: 'camera; microphone; autoplay',
                          iframeAllowFullscreen: true,
                        ),
                        onWebViewCreated: (controller) {
                          webController = controller;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            loadingWebView = true;
                            _progress = 0;
                          });
                        },
                        onProgressChanged: (controller, progress) {
                          setState(() => _progress = progress / 100);
                        },
                        onLoadStop: (controller, url) {
                          setState(() {
                            loadingWebView = false;
                            _progress = 1;
                            webController = controller;
                          });
                        },
                        onReceivedError: (controller, request, error) {
                          setState(() => loadingWebView = false);
                        },
                        onReceivedServerTrustAuthRequest:
                            (controller, challenge) async {
                          return ServerTrustAuthResponse(
                            action: ServerTrustAuthResponseAction.PROCEED,
                          );
                        },
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT,
                          );
                        },
                      ),
                      if (loadingWebView || _progress < 1)
                        LinearProgressIndicator(
                          value: _progress > 0 && _progress < 1
                              ? _progress
                              : null,
                          minHeight: 3,
                          color: AppUi.accent,
                          backgroundColor: AppUi.line(context),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
