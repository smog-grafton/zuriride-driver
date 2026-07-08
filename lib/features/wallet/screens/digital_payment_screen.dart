import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class DigitalPaymentScreen extends StatefulWidget {
  final String paymentMethod;
  final String totalAmount;
  const DigitalPaymentScreen(
      {super.key, required this.paymentMethod, required this.totalAmount});

  @override
  State<DigitalPaymentScreen> createState() => _DigitalPaymentScreenState();
}

class _DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  String? selectedUrl;
  double value = 0.0;
  bool _isLoading = true;
  final TextEditingController _phoneController = TextEditingController();

  PullToRefreshController? pullToRefreshController;
  late AddFundInAppBrowser browser;

  @override
  void initState() {
    super.initState();
    _phoneController.text = Get.find<ProfileController>().profileInfo?.phone ?? '';

    if (widget.paymentMethod == 'iotec') {
      _isLoading = false;
      return;
    }

    selectedUrl =
        '${AppConstants.baseUrl}${AppConstants.digitalPayment}?user_id=${Get.find<ProfileController>().profileInfo?.id}&amount=${widget.totalAmount}&payment_method=${widget.paymentMethod}';
    _initData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _initData() async {
    browser = AddFundInAppBrowser(context);
    final settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: false),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          isInspectable: kDebugMode,
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true),
    );

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl!)),
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, val) async {
          Get.back();
          return;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.paymentMethod == 'iotec' ? 'deposit'.tr : ''),
              backgroundColor: Theme.of(context).cardColor),
          body: widget.paymentMethod == 'iotec'
              ? _IotecDepositForm(
                  amount: widget.totalAmount,
                  phoneController: _phoneController,
                )
              : Center(
              child: _isLoading
                  ? SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 40.0,
                    )
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

class _IotecDepositForm extends StatelessWidget {
  final String amount;
  final TextEditingController phoneController;

  const _IotecDepositForm({
    required this.amount,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      final String? status = walletController.latestIotecStatus;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('deposit_cash_collected'.tr, style: textSemiBold),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text('amount_owed_to_company'.tr,
                      style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(amount,
                      style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text('mobile_money_number'.tr, style: textSemiBold),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('a_payment_request_will_be_sent_to_this_number'.tr,
                style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'enter_mobile_money_number'.tr,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            ),

            if (status != null) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: (status == 'confirmed'
                          ? Colors.green
                          : status == 'failed'
                              ? Theme.of(context).colorScheme.error
                              : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(children: [
                  Icon(
                    status == 'confirmed'
                        ? Icons.check_circle
                        : status == 'failed'
                            ? Icons.error
                            : Icons.hourglass_top,
                    size: 18,
                    color: status == 'confirmed'
                        ? Colors.green
                        : status == 'failed'
                            ? Theme.of(context).colorScheme.error
                            : Colors.orange,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      status == 'confirmed'
                          ? 'payment_confirmed'.tr
                          : status == 'failed'
                              ? 'payment_failed_please_try_again'.tr
                              : 'payment_pending_confirm_on_your_phone'.tr,
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeLarge),

            ButtonWidget(
              buttonText: walletController.isLoading
                  ? 'loading'.tr
                  : 'pay_company'.tr,
              onPressed: walletController.isLoading
                  ? null
                  : () {
                      final phone = phoneController.text.trim();
                      if (phone.isEmpty) {
                        showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
                        return;
                      }
                      walletController.depositViaIotec(amount, phone);
                    },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ButtonWidget(
              buttonText: 'check_payment_status'.tr,
              transparent: true,
              showBorder: true,
              onPressed: walletController.isLoading ||
                      walletController.latestIotecPaymentId == null
                  ? null
                  : walletController.checkIotecPaymentStatus,
            ),
          ],
        ),
      );
    });
  }
}

class AddFundInAppBrowser extends InAppBrowser {
  final BuildContext context;

  AddFundInAppBrowser(
    this.context, {
    super.windowId,
    super.initialUserScripts,
  });

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _pageRedirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _pageRedirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if (_canRedirect) {
      Get.back();

      Future.delayed(Duration(microseconds: 500)).then((_) {
        showCustomSnackBar('${'transaction_failed'.tr} !');
      });
    }

    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    Uri uri = navigationAction.request.url!;
    if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
        .contains(uri.scheme)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {}

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _pageRedirect(String url) {
    if (_canRedirect) {
      bool isSuccess =
          url.contains('success') && url.contains(AppConstants.baseUrl);
      bool isFailed =
          url.contains('fail') && url.contains(AppConstants.baseUrl);
      bool isCancel =
          url.contains('cancel') && url.contains(AppConstants.baseUrl);
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }
      if (isSuccess) {
        Get.back();
        showCustomSnackBar('${'amount_paid_successfully'.tr} !',
            isError: false);
        Get.find<ProfileController>().getProfileInfo();
      } else if (isFailed) {
        Get.back();
        Future.delayed(Duration(microseconds: 500)).then((_) {
          showCustomSnackBar('${'transaction_failed'.tr} !');
        });
      } else if (isCancel) {
        Get.back();
        Future.delayed(Duration(microseconds: 500)).then((_) {
          showCustomSnackBar('${'transaction_failed'.tr} !');
        });
      }
    }
  }
}
