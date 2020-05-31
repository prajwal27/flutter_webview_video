import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwebviewvideo/features/presentation/components/navigation_controls.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  String _title = 'Himdeve Shop';
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  Widget _buildChangeTitleBtn() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _title = 'Himdeve Development Tutorial';
        });
      },
      child: Icon(Icons.link),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),
      body: _buildWebView(),
      floatingActionButton: _buildShowUrlBtn(),
    );;
  }

  Widget _buildWebView() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: 'https://himdeve.eu',
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      navigationDelegate: (request) {
        return _buildNavigationDecision(request);
      },
      onPageFinished: (url) {
        _showPageTitle();
      },
      javascriptChannels: <JavascriptChannel>[
        _createTopBarJsChannel(),
      ].toSet(),
    );
  }

  JavascriptChannel _createTopBarJsChannel() {
    return JavascriptChannel(
      name: 'TopBarJsChannel',
      onMessageReceived: (JavascriptMessage message) {
        String newTitle = message.message;
        globalKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              newTitle,
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
        if (newTitle.contains('-')) {
          newTitle = newTitle.substring(0, newTitle.indexOf('-')).trim();
        }

        setState(() {
          _title = newTitle;
        });
      },
    );
  }

  void _showPageTitle() {
    _controller.future.then((webViewController) {
      webViewController
          .evaluateJavascript('TopBarJsChannel.postMessage(document.title);');
    });
  }

  Widget _buildShowUrlBtn() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              var url = await controller.data.currentUrl();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                      'Current url is: $url',
                      style: TextStyle(fontSize: 20),
                    )),
              );
            },
            child: Icon(Icons.link),
          );
        }

        return Container();
      },
    );
  }

  NavigationDecision _buildNavigationDecision(NavigationRequest request) {
    if (request.url.contains('my-account')) {
      globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'You do not have rights to access My Account page',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }
}
