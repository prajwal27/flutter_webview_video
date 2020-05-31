import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
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
      appBar: AppBar(
        title: Text('Himdeve Shop'),
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
    );
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
}
