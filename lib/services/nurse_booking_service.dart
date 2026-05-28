import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/model/booking_model.dart';
import '../resources/utils/error_handler.dart';

class NurseBookingService {
  // Creating a firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Creating a firebase real-time database instance in which I will create a new database node 'NurseBookings'
  final DatabaseReference _bookings = FirebaseDatabase.instance.ref(
    'NurseBookings',
  );

  // Creating a method that will help save bookings onto Firebase
  // Returns null on success, or an error message on failure
  Future<void> bookNurse({
    required String nurseId, //id for who is being booked in this case nurse
    required String date, // formated 'MM/dd/yyyy'
    required String time, // formated '10:30 AM'
    required int hours, // number of hours hired
    required double totalFee, //calculated; hours * hourlyRate
    required String description,
  }) async {
    // getting current user id
    final String? currentUserId = _auth.currentUser?.uid;
    // Safety check: user must be logged-in to book
    if (currentUserId == null)
      throw const AppException('You must be logged in to book.');
    try {
      // Also, checking if a pending booking/hiring request already exists for this nurse
      final existingRequest = await _bookings
          .orderByChild('patientId')
          .equalTo(currentUserId)
          .get()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw AppException('Request timed out. Please check internet.'),
          );
      // If there is a pending request, then transform data into a map
      if (existingRequest.exists) {
        final Map<dynamic, dynamic> data =
            existingRequest.value as Map<dynamic, dynamic>;
        // Now we loop through existing bookings
        for (final entry in data.entries) {
          // entries gives us Map-object with key, values(id, data)
          // Also convert every entry into a map
          final booking = entry.value as Map<dynamic, dynamic>;
          if (booking['nurseId'] == nurseId && booking['status'] == 'pending') {
            throw const AppException(
              'You already have a pending request for this nurse',
            );
          }
        }
      }
      // If no already sent request is not found then
      // We, Generate a unique-id/key for booking
      final String bookingId = _bookings.push().key!;
      // Now, we save booking data in the database using booking id
      await _bookings
          .child(bookingId)
          .set({
            'bookingId': bookingId,
            'nurseId': nurseId,
            'patientId': currentUserId,
            'date': date,
            'time': time,
            'hours': hours,
            'totalFee': totalFee,
            'description': description,
            'status': 'pending', //nurse-side can update this
            'createdAt': DateTime.now().toIso8601String(),
          })
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw AppException('Request timed out. Please check internet.'),
          );
    } catch (e) {
      // 'ErrorHandler.parse' converts Firebase/socket/unknown error
      // into clean user-facing messages, then we wrap in AppException
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // Now, we write method for cancelling bookings by setting status to cancelled
  // This method will be called when the status is pending
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookings
          .child(bookingId)
          .update({'status': 'cancelled'})
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw AppException('Request timed out. Please check internet.'),
          );
    } catch (e) {
      // 'ErrorHandler.parse' converts Firebase/socket/unknown error
      // into clean user-facing messages, then we wrap in AppException
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // Method for deleting booking--- only soft delete sets 'isDeleted' flag instead of removing booking from Firebase
  // This saves records while hiding them from the patient's view
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookings
          .child(bookingId)
          .update({'isDeleted': true})
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw AppException('Request timed out. Please check internet.'),
          );
    } catch (e) {
      // 'ErrorHandler.parse' converts Firebase/socket/unknown error
      // into clean user-facing messages, then we wrap in AppException
      throw AppException(ErrorHandler.parse(e));
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    try {
      await _bookings
          .child(bookingId)
          .update({'status': status})
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw AppException('Request timed out. Please check internet.'),
          );
    } catch (e) {
      // 'ErrorHandler.parse' converts Firebase/socket/unknown error
      // into clean user-facing messages, then we wrap in AppException
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // Now we create stream of bookings for the current patient
  // StreamBuilder will listen to this and rebuild UI on every change
  // Fetch all the bookings where patientId matches
  Stream<List<BookingModel>> getPatientBookings(String patientId) {
    return _bookings
        .orderByChild('patientId') //filter by patient
        .equalTo(patientId)
        .onValue // this executes or fires on every Firebase change
        .map((event) {
          try {
            // event.snapshot.value is the raw data from Firebase,
            // if it is null then return an empty list
            if (event.snapshot.value == null) return [];
            // Now we convert each raw Firebase data into our BookingModel
            // Also filter out soft-deleted ones
            final Map<dynamic, dynamic> data =
                event.snapshot.value as Map<dynamic, dynamic>;
            return data.entries
                .map(
                  (e) => BookingModel.fromMap(
                    e.value as Map<dynamic, dynamic>,
                    e.key.toString(),
                  ),
                )
                .where((booking) => !booking.isDeleted) // we hide deleted
                .toList()
              // Also we sort the bookings from newest to oldest using 'createdAt'
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } on AppException {
            rethrow;
          } catch (e) {
            throw AppException(ErrorHandler.parse(e));
          }
        });
  }

  // Now we create stream of bookings for the current nurse
  // StreamBuilder will listen to this and rebuild UI on every change
  // Fetches all the bookings where nurseId matches
  Stream<List<BookingModel>> getNurseBookings(String nurseId) {
    return _bookings
        .orderByChild('nurseId') //filter by nurse
        .equalTo(nurseId)
        .onValue // this executes or fires on every Firebase change
        .map((event) {
          try {
            // event.snapshot.value is the raw data from Firebase,
            // if it is null then return an empty list
            if (event.snapshot.value == null) return [];
            // Now we convert each raw Firebase data into our BookingModel
            // Also filter out soft-deleted ones
            final Map<dynamic, dynamic> data =
                event.snapshot.value as Map<dynamic, dynamic>;
            return data.entries
                .map(
                  (e) => BookingModel.fromMap(
                    e.value as Map<dynamic, dynamic>,
                    e.key.toString(),
                  ),
                )
                .where((booking) => !booking.isDeleted) // we hide deleted
                .toList()
              // Also we sort the bookings from newest to oldest using 'createdAt'
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } on AppException {
            rethrow;
          } catch (e) {
            throw AppException(ErrorHandler.parse(e));
          }
        });
  }
}
