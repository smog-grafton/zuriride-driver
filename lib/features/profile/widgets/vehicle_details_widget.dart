import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/screens/vehicle_add_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_item_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class VehicleDetailsWidget extends StatelessWidget {
  const VehicleDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController){
      final List<String> vehiclePhotos =
          profileController.profileInfo?.vehicle?.photos ?? [];
      final String vehiclePhotoBaseUrl =
          Get.find<SplashController>().config?.imageBaseUrl?.vehiclePhoto ?? '';

      return profileController.profileInfo!.vehicle != null ?
      Container(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
            color: Theme.of(context).highlightColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
        ),
        child: Column(children: [
          if(vehiclePhotos.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vehiclePhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: ImageWidget(
                    height: 110, width: 150, fit: BoxFit.cover,
                    image: '$vehiclePhotoBaseUrl/${vehiclePhotos[index]}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],

          ProfileItemWidget(title: 'vehicle_category_type',
            value: profileController.profileInfo?.vehicle?.category?.type?.tr ?? '',
          ),

          ProfileItemWidget(title: 'vehicle_category',
            value: profileController.profileInfo?.vehicle?.category?.name?.tr ?? '',
          ),

          ProfileItemWidget(title: 'vehicle_brand',
            value: profileController.profileInfo?.vehicle?.brand?.name
                ?? profileController.profileInfo?.vehicle?.brandName ?? '',
          ),

          ProfileItemWidget(title: 'vehicle_model',
            value: profileController.profileInfo?.vehicle?.model?.name
                ?? profileController.profileInfo?.vehicle?.modelName ?? '',
          ),

          if(_isShowParcelWeight(profileController.profileInfo?.details?.services))
            ProfileItemWidget(title: 'parcel_weight_capacity',
              value: '${profileController.profileInfo?.vehicle?.parcelWeightCapacity ?? 'unlimited'.tr} ${Get.find<SplashController>().config?.parcelWeightUnit}',
            ),

          ProfileItemWidget(title: 'license_number_plate',
            value: profileController.profileInfo?.vehicle?.licencePlateNumber ?? '',
          ),

          ProfileItemWidget(title: 'license_expire_date',
            value: DateConverter.isoStringToLocalDateOnly(
              profileController.profileInfo?.vehicle?.licenceExpireDate ?? '',
            ),
          ),

          ProfileItemWidget(title: 'fuel_type',
            value: profileController.profileInfo?.vehicle?.fuelType ?? '',
            isLastIndex: true,
          ),
        ]),
      ) :
      Padding(padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(children: [
          Image.asset(
            Images.noVehicleFound,
            height: Get.height * 0.3,
            width: Get.width * 0.7,
          ),

          Text('ready_to_drive'.tr,style: textBold,textAlign: TextAlign.center),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            'you_have_allmost_ready'.tr,textAlign: TextAlign.center,
            style: textRegular.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ButtonWidget(width: 150,
              buttonText: 'add_vehicle'.tr,
              onPressed: () => Get.to(()=> const VehicleAddScreen())
          )
        ]),
      );
    });
  }

  bool _isShowParcelWeight(List<String>? services){
    if(services == null){
      return false;
    }else{
      if(services.contains('parcel')){
        return true;
      }else{
        return false;
      }
    }
  }
}
