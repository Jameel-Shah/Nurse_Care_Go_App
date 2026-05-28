class BookingModel {
  final String bookingId;
  final String patientId;
  final String nurseId;
  final String date;
  final String time;
  final int hours;
  final double totalFee;
  final String description;
  final String status; // 'pending', 'accepted', 'rejected'
  final String createdAt;
  final bool isDeleted; // soft delete flag never har delete

  const BookingModel({
    required this.bookingId,
    required this.patientId,
    required this.nurseId,
    required this.date,
    required this.time,
    required this.hours,
    required this.totalFee,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.isDeleted,
  });

  // 'factory' method helps convert raw Firebase-map into actual map of our BookingModel
  // Every field has a fallback so it never crashes on missing data
  factory BookingModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return BookingModel(
      bookingId: id,
      patientId: map['patientId'] ?? '',
      nurseId: map['nurseId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      // tryParse protects against type-mismatches from Firebase
      hours: int.tryParse(map['hours'].toString()) ?? 0,
      totalFee: double.tryParse(map['totalFee'].toString()) ?? 0.0,
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  // Now we convert or model-> So, we can write data in Firebase
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'patientId': patientId,
      'nurseId': nurseId,
      'date': date,
      'time': time,
      'hours': hours,
      'totalFee': totalFee,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }
}
