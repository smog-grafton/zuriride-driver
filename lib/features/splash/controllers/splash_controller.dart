import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/splash_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _config;

  ConfigModel? get config => _config;
  bool isShowToolTips = true;
  bool loading = false;
  Future<bool> getConfigData({bool reload= true}) async {
    loading = true;
    Response response = await splashServiceInterface.getConfigData();
    bool isSuccess = false;
    if(response.statusCode == 200) {
      isSuccess = true;
      loading = false;
      _config = ConfigModel.fromJson(response.body);
      _syncFloatingOverlaySetting();
    }else {
      loading = false;
      ApiChecker.checkApi(response);
    }
    if(reload){
      update();
    }
    return isSuccess;
  }

  /// Persist the overlay flag so the FCM background isolate (which has no
  /// access to controllers) can decide whether to show floating request
  /// alerts. The permission itself is requested through an explanatory
  /// dialog on the dashboard (NotificationHelper.maybePromptFloatingAlerts).
  Future<void> _syncFloatingOverlaySetting() async {
    try {
      final bool enabled = _config?.driverFloatingOverlayEnabled ?? false;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.floatingOverlayEnabled, enabled);
    } catch (_) {}
  }

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }



  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<void> sendMailOrCall(String url, bool isMail) async {
    final Uri uri = _buildContactUri(url, isMail);
    final String contactValue = _extractContactValue(uri);

    if(contactValue.isEmpty || contactValue.toLowerCase() == 'null'){
      showCustomSnackBar(isMail ? 'email_is_required'.tr : 'phone_is_required'.tr);
      return;
    }

    if(await canLaunchUrl(uri)){
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if(launched){
        return;
      }
    }

    await _showContactFallbackDialog(contactValue, isMail);
  }

  Uri _buildContactUri(String value, bool isMail) {
    final String normalizedValue = value.trim();
    if(isMail){
      return Uri(
        scheme: 'mailto',
        path: normalizedValue.replaceFirst(RegExp(r'^mailto:'), ''),
        query: 'subject=support Feedback&body=',
      );
    }

    final String phoneValue = normalizedValue.startsWith('tel:') ? normalizedValue : 'tel:$normalizedValue';
    return Uri.parse(phoneValue);
  }

  String _extractContactValue(Uri uri) {
    return uri.path.trim();
  }

  Future<void> _showContactFallbackDialog(String contactValue, bool isMail) async {
    await Get.dialog(AlertDialog(
      title: Text(isMail ? 'email'.tr : 'call'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isMail ? 'email'.tr : 'phone'.tr),
          const SizedBox(height: 8),
          SelectableText(contactValue),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('ok'.tr),
        ),
      ],
    ));
  }


  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection){
    _pusherConnectionStatus = connection;
  }


  bool haveOngoingRides() {
    return splashServiceInterface.haveOngoingRides();
  }

  void saveOngoingRides(bool value) {
    return splashServiceInterface.saveOngoingRides(value);
  }

  void addLastReFoundData(Map<String,dynamic>? data) => splashServiceInterface.addLastReFoundData(data);
  Map<String, dynamic>? getLastRefundData() => splashServiceInterface.getLastRefundData();

  void hideToolTips(){
    isShowToolTips = false;
  }

}
