import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/driver_document_request_model.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Dashboard alert shown when the admin has requested a document from the
/// driver. Also pops a one-time dialog per session so the request cannot be
/// missed.
class DocumentRequestAlertWidget extends StatefulWidget {
  const DocumentRequestAlertWidget({super.key});

  @override
  State<DocumentRequestAlertWidget> createState() =>
      _DocumentRequestAlertWidgetState();
}

class _DocumentRequestAlertWidgetState
    extends State<DocumentRequestAlertWidget> {
  static bool _dialogShownThisSession = false;

  List<DriverDocumentRequestModel> _openRequests(
      ProfileController controller) {
    return controller.driverDocumentRequests
        .where((request) => ['pending', 'resubmission_required', 'locked']
            .contains(request.status))
        .toList();
  }

  void _goToDocuments() {
    Get.find<ProfileController>().setProfileTypeIndex(0, isUpdate: true);
    Get.to(() => const ProfileScreen());
  }

  void _maybeShowDialog(List<DriverDocumentRequestModel> requests) {
    if (_dialogShownThisSession || requests.isEmpty) {
      return;
    }
    _dialogShownThisSession = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = requests.first;
      final bool locked = request.status == 'locked';
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
        title: Row(children: [
          Icon(locked ? Icons.lock : Icons.description,
              color: locked
                  ? Theme.of(Get.context!).colorScheme.error
                  : Colors.orange.shade800),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
              child: Text(
                  locked ? 'account_locked'.tr : 'document_required'.tr,
                  style: textBold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            request.adminNote?.isNotEmpty ?? false
                ? request.adminNote!
                : 'submit_the_requested_document_to_keep_accepting_trips'.tr,
            style: textRegular,
          ),
          if (request.lockAfter?.isNotEmpty ?? false) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('${'deadline'.tr}: ${request.lockAfter}',
                style: textSemiBold.copyWith(
                    color: Theme.of(Get.context!).colorScheme.error)),
          ],
        ]),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('later'.tr,
                  style: textRegular.copyWith(
                      color: Theme.of(Get.context!).hintColor))),
          TextButton(
              onPressed: () {
                Get.back();
                _goToDocuments();
              },
              child: Text('submit_document'.tr, style: textSemiBold)),
        ],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      final requests = _openRequests(profileController);
      if (requests.isEmpty) {
        return const SizedBox.shrink();
      }

      _maybeShowDialog(requests);

      final request = requests.first;
      final bool locked = request.status == 'locked' ||
          (profileController.profileInfo?.isSuspended == true &&
              profileController.profileInfo?.suspendReason ==
                  'document_request');
      final Color accent = locked
          ? Theme.of(context).colorScheme.error
          : Colors.orange.shade800;

      return Container(
        margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(locked ? Icons.lock : Icons.description, color: accent),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                locked ? 'account_locked'.tr : 'document_required'.tr,
                style: textBold.copyWith(color: accent),
              ),
            ),
            if (requests.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                decoration: BoxDecoration(
                    color: accent,
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeSmall)),
                child: Text('${requests.length}',
                    style: textSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeSmall)),
              ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            request.adminNote?.isNotEmpty ?? false
                ? request.adminNote!
                : 'submit_the_requested_document_to_keep_accepting_trips'.tr,
            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
          if (request.lockAfter?.isNotEmpty ?? false) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('${'deadline'.tr}: ${request.lockAfter}',
                style: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: accent)),
          ],
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ButtonWidget(
            buttonText:
                locked ? 'submit_document_to_unlock'.tr : 'submit_document'.tr,
            height: 40,
            radius: Dimensions.paddingSizeSmall,
            backgroundColor: accent,
            onPressed: _goToDocuments,
          ),
        ]),
      );
    });
  }
}
