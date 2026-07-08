class VehicleBody {
  String? brandId;
  String? brandName;
  String? modelId;
  String? modelName;
  String? categoryId;
  String? licencePlateNumber;
  String? licenceExpireDate;
  String? vinNumber;
  String? transmission;
  String? fuelType;
  String? driverId;
  String? ownership;
  String? parcelCapacityWeight;

  VehicleBody(
      {this.brandId,
        this.brandName,
        this.modelId,
        this.modelName,
        this.categoryId,
        this.licencePlateNumber,
        this.licenceExpireDate,
        this.vinNumber,
        this.transmission,
        this.fuelType,
        this.driverId,
        this.ownership,
        this.parcelCapacityWeight
      });

  VehicleBody.fromJson(Map<String, dynamic> json) {
    brandId = json['brand_id'];
    brandName = json['brand_name'];
    modelId = json['model_id'];
    modelName = json['model_name'];
    categoryId = json['category_id'];
    licencePlateNumber = json['licence_plate_number'];
    licenceExpireDate = json['licence_expire_date'];
    vinNumber = json['vin_number'];
    transmission = json['transmission'];
    fuelType = json['fuel_type'];
    driverId = json['driver_id'];
    ownership = json['ownership'];
    parcelCapacityWeight = json['parcel_weight_capacity'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    if (brandId?.isNotEmpty ?? false) {
      data['brand_id'] = brandId!;
    }
    if (brandName?.isNotEmpty ?? false) {
      data['brand_name'] = brandName!;
    }
    if (modelId?.isNotEmpty ?? false) {
      data['model_id'] = modelId!;
    }
    if (modelName?.isNotEmpty ?? false) {
      data['model_name'] = modelName!;
    }
    data['category_id'] = categoryId!;
    data['licence_plate_number'] = licencePlateNumber!;
    data['licence_expire_date'] = licenceExpireDate!;
    data['vin_number'] = vinNumber!;
    data['transmission'] = transmission!;
    data['fuel_type'] = fuelType!;
    data['driver_id'] = driverId!;
    data['ownership'] = ownership!;
    data['parcel_weight_capacity'] = parcelCapacityWeight!;
    return data;
  }
}
