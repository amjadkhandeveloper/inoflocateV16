import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:infolocate/utils/app_lifecycle.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/utils/orientation_helper.dart';
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
  /// Pulls the camera grid up so the empty band under the app bar is covered.
  static const _coverTopScript = '''
(function() {
  var html = document.documentElement;
  var body = document.body;
  if (!html || !body) return;
  html.style.background = '#000';
  html.style.margin = '0';
  html.style.padding = '0';
  html.style.overflow = 'hidden';
  body.style.background = '#000';
  body.style.margin = '0';
  body.style.padding = '0';
  body.style.overflow = 'hidden';
  body.style.transform = 'none';
  body.style.width = '100%';
  var vh = window.innerHeight || html.clientHeight;
  var vw = window.innerWidth || html.clientWidth;
  if (!vh || !vw) return;
  var top = null;
  var nodes = body.getElementsByTagName('*');
  for (var i = 0; i < nodes.length; i++) {
    var r = nodes[i].getBoundingClientRect();
    if (r.top < 0) continue;
    if (r.width < vw * 0.35 || r.width > vw * 0.65) continue;
    if (r.height < vh * 0.18 || r.height > vh * 0.62) continue;
    if (top === null || r.top < top) top = r.top;
  }
  if (top === null || top < 4) return;
  if (top > vh * 0.22) top = vh * 0.22;
  var scale = vh / (vh - top);
  body.style.transformOrigin = 'top center';
  body.style.transform = 'translateY(' + (-top) + 'px) scale(' + scale + ')';
})();
''';

  bool loadingWebView = true;
  double _progress = 0;
  InAppWebViewController? webController;
  /// Fresh webview on rotate avoids sticky layout from the previous mode.
  int _webViewGeneration = 0;
  Orientation _orientation = Orientation.portrait;

  WebUri? get _replayUri {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return null;
    return WebUri(raw, forceToStringRawValue: true);
  }

  @override
  void initState() {
    super.initState();
    AppLifecycleTracker.instance.beginSuppressBackgroundRefresh();
    _orientation = Orientation.portrait;
    OrientationHelper.lockPortrait();
  }

  @override
  void dispose() {
    AppLifecycleTracker.instance.endSuppressBackgroundRefresh();
    OrientationHelper.lockPortrait();
    super.dispose();
  }

  InAppWebViewSettings _settingsFor(Orientation orientation) {
    final portrait = orientation == Orientation.portrait;
    return InAppWebViewSettings(
      javaScriptEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      useHybridComposition: true,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      // Overview scaling letterboxes the page and leaves a white strip
      // under the app bar. Render at the page's own size instead.
      useWideViewPort: false,
      loadWithOverviewMode: false,
      enableViewportScale: false,
      ignoresViewportScaleLimits: false,
      minimumZoomScale: 1.0,
      maximumZoomScale: 5.0,
      pageZoom: 1.0,
      preferredContentMode: UserPreferredContentMode.MOBILE,
      // Portrait: no scroll. Landscape: allow scroll.
      horizontalScrollBarEnabled: !portrait,
      verticalScrollBarEnabled: !portrait,
      disableHorizontalScroll: portrait,
      disableVerticalScroll: portrait,
      iframeAllow: 'autoplay; fullscreen',
      iframeAllowFullscreen: true,
      transparentBackground: true,
      underPageBackgroundColor: Colors.black,
    );
  }

  Future<void> _coverTopGap(InAppWebViewController controller) async {
    for (final wait in [0, 350, 900, 1600]) {
      if (wait > 0) {
        await Future<void>.delayed(Duration(milliseconds: wait));
      }
      if (!mounted || webController != controller) return;
      await controller.evaluateJavascript(source: _coverTopScript);
    }
  }

  Future<void> _toggleRotation() async {
    if (_orientation == Orientation.landscape) {
      await OrientationHelper.lockPortrait();
      _orientation = Orientation.portrait;
    } else {
      await OrientationHelper.lockLandscape();
      _orientation = Orientation.landscape;
    }
    if (!mounted) return;
    setState(() {
      loadingWebView = true;
      _progress = 0;
      _webViewGeneration++;
      webController = null;
    });
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
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        appBar: AppUi.appBar(
          context: context,
          title: widget.title ?? 'Video Playback',
          actions: [
            IconButton(
              tooltip: 'Open in browser',
              onPressed: _openInSystemBrowser,
              icon: const Icon(
                Icons.open_in_browser,
                color: AppUi.toolbarFg,
              ),
            ),
            IconButton(
              tooltip: 'Rotate',
              onPressed: _toggleRotation,
              icon: const Icon(
                Icons.screen_rotation_alt_outlined,
                color: AppUi.toolbarFg,
              ),
            ),
          ],
        ),
        body: replayUri == null
            ? Center(
                child: Text(
                  'No playback URL',
                  style: AppUi.mutedStyle(context).copyWith(
                    color: Colors.white70,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: InAppWebView(
                      key: ValueKey('live-video-$_webViewGeneration'),
                      initialUrlRequest: URLRequest(url: replayUri),
                      initialSettings: _settingsFor(_orientation),
                      initialUserScripts: UnmodifiableListView<UserScript>([
                        UserScript(
                          source: _coverTopScript,
                          injectionTime:
                              UserScriptInjectionTime.AT_DOCUMENT_END,
                        ),
                      ]),
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
                        _coverTopGap(controller);
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
                  ),
                  if (loadingWebView || _progress < 1)
                    const Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                ],
              ),
      ),
    );
  }
}
