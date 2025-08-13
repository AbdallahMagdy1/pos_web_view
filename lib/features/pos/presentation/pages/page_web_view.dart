import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/features/pos/data/data_sources/blue_printer_data_source.dart';
import 'package:pos/features/pos/data/repo/pos_repo_impl.dart';
import 'package:pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:pos/features/pos/presentation/widgets/printer_connection_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PosWebViewPage extends StatelessWidget {
  const PosWebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PosBloc(
        repository: PosRepositoryImpl(
          localDataSource: NetworkPrinterDataSource(),
        ),
        localDataSource: NetworkPrinterDataSource(),
      ),
      child: const _PosWebViewView(),
    );
  }
}

class _PosWebViewView extends StatefulWidget {
  const _PosWebViewView();

  @override
  State<_PosWebViewView> createState() => _PosWebViewViewState();
}

class _PosWebViewViewState extends State<_PosWebViewView> {
  late final WebViewController _controller;
  final String posUrl = 'https://pos.conchahotel.com';

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    context.read<PosBloc>().add(CheckConnectionEvent());
  }

  void _initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(posUrl));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4455aa),
      appBar: AppBar(
        backgroundColor: const Color(0xff445566),
        title: const Text('Concha Hotel POS'),
        actions: const [PrinterConnectionButton()],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
