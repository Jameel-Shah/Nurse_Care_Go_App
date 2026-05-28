// Making a model class so, we can fetch nurse data from database
class NurseModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String city;
  final String provinceRegion;
  final String address;
  final String profileImageUrl;
  final String gender;
  final String qualification;
  final String yearsOfExperience;
  final String categorySpecialization;
  final String availability;
  final String workPlace;
  final double latitude;
  final double longitude;
  final double serviceFee;
  final int totalReviews;
  final double averageRating;

  NurseModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.provinceRegion,
    required this.address,
    required this.profileImageUrl,
    required this.gender,
    required this.qualification,
    required this.yearsOfExperience,
    required this.categorySpecialization,
    required this.workPlace,
    required this.latitude,
    required this.longitude,
    required this.totalReviews,
    required this.averageRating, required this.availability, required this.serviceFee
  });

  factory NurseModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return NurseModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'] ?? '',
      city: map['city'],
      provinceRegion: map['provinceRegion'] ?? '',
      address: map['address'],
      profileImageUrl: map['profileImageUrl'] ?? '',
      gender: map['gender']?? '',
      qualification: map['qualification']?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? '',
      categorySpecialization: map['categorySpecialization'] ?? '',
      availability: map['availability'] ?? '',
      serviceFee: double.tryParse(map['serviceFee'].toString())?? 0.0,
      workPlace: map['workPlace']?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews']?? 0,
      averageRating: map['averageRating']?.toDouble() ?? 0.0
    );
  }
}
