// Making a model class so, we can fetch patient data from database
class PatientModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String city;
  final String provinceRegion;
  final String address;
  final String profileImageUrl;
  final double latitude;
  final double longitude;

  PatientModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.provinceRegion,
    required this.address,
    required this.profileImageUrl,
    required this.latitude,
    required this.longitude,
  });

  // Fetch data from database
  factory PatientModel.fromMap(Map<dynamic, dynamic> data, String uid) {
    return PatientModel(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      city: data['city'] ?? '',
      provinceRegion: data['provinceRegion'],
      address: data['address'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'city': city,
      'provinceRegion': provinceRegion,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
