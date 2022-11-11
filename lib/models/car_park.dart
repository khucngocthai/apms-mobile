class CarPark {
  String id, name, addressNumber, phoneNumber, street, ward, district, city;
  int availableSlotsCount, provinceId;
  bool status;

  CarPark.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        addressNumber = json["addressNumber"],
        phoneNumber = json["phoneNumber"],
        availableSlotsCount = json["availableSlotsCount"] as int,
        provinceId = json["provinceId"] as int,
        status = json["status"] == 1 ? true : false,
        street = json["street"],
        ward = json["ward"],
        district = json["district"],
        city = json["city"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "addressNumber": addressNumber,
        "phoneNumber": phoneNumber,
        "availableSlotsCount": availableSlotsCount,
        "provinceId": provinceId,
        "status": status,
        "stret": street,
        "ward": ward,
        "district": district,
        "city": city
      };
}