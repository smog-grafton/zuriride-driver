import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/driver_document_request_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/file_validation_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DriverDocumentRequestWidget extends StatefulWidget {
  const DriverDocumentRequestWidget({super.key});

  @override
  State<DriverDocumentRequestWidget> createState() =>
      _DriverDocumentRequestWidgetState();
}

class _DriverDocumentRequestWidgetState
    extends State<DriverDocumentRequestWidget> {
  final Map<String, PlatformFile> _selectedFiles = {};

  Future<void> _pickFile(String requestId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png', 'webp', 'pdf', 'doc', 'docx'],
      withReadStream: true,
    );

    if (result == null) {
      return;
    }

    final file = result.files.single;
    if (await FileValidationHelper.validatePlatformFileSizeAsync(file: file)) {
      setState(() => _selectedFiles[requestId] = file);
    }
  }

  Future<void> _submit(
      ProfileController controller, DriverDocumentRequestModel request) async {
    final file = _selectedFiles[request.id];
    if (file?.path == null) {
      showCustomSnackBar('please_select_document'.tr);
      return;
    }

    await controller.submitDriverDocumentRequest(request.id, [
      MultipartBody('documents[]', XFile(file!.path!)),
    ]);
    setState(() => _selectedFiles.remove(request.id));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      final requests = profileController.driverDocumentRequests
          .where((request) => !['approved', 'rejected'].contains(request.status))
          .toList();

      if (requests.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('document_requests'.tr, style: textBold),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...requests.map((request) {
              final selected = _selectedFiles[request.id];
              return Container(
                margin:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.additionalFieldTitle,
                        style: textSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                    if (request.adminNote?.isNotEmpty ?? false) ...[
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(request.adminNote!, style: textRegular),
                    ],
                    if (request.lockAfter?.isNotEmpty ?? false) ...[
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text('${'deadline'.tr}: ${request.lockAfter}',
                          style: textRegular.copyWith(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    InkWell(
                      onTap: () => _pickFile(request.id),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(selected?.name ?? 'select_document'.tr,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ButtonWidget(
                      buttonText: 'submit_document'.tr,
                      onPressed: profileController.isLoading
                          ? null
                          : () => _submit(profileController, request),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
