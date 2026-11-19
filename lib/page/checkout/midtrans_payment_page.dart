import 'package:flutter/material.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String snapToken;
  const MidtransPaymentPage({super.key, required this.snapToken});
  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('${AppConfig.URL_PAYMENT}${widget.snapToken}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/order')),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
