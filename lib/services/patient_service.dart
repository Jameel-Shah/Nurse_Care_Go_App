import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/model/patient_model.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';

class PatientService {
  // A Reference path that points to 'Patients' database
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child(
    'Patients',
  );

  // Method for fetching data from the 'Patients' database by id
  Future<PatientModel?> fetchPatient(String patientId) async {
    // .child(patientId) means going deeper into the database to a specific patient
    // .once() means "Read this data one time and stop"
    // It returns an DatabaseEvent object
    final event = await _db
        .child(patientId)
        .once()
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw AppException(
            'Something went wrong, check your internet connection and try again',
          ),
        );
    // DatabaseEvent contains a DatabaseSnapshot
    // DataSnapshot is Firebase's wrapper around raw data
    // It holds value & the key (id)
    final snapShot = event.snapshot;
    // snapShot.value is the actual data but it comes as dynamic - unknown type
    // We check if it is null first like if the patient doesn't exist in the database
    if (snapShot.value != null) {
      // Cast it to Map so we can read data fields like map['firstName']
      // Also passing the patientId
      // dynamic, dynamic means both key and value type are un-known
      return PatientModel.fromMap(
        snapShot.value as Map<dynamic, dynamic>,
        patientId,
      );
    }
    return null; // Patient not found in the database
  }

  // Method for updating patient data
  Future<void> updatePatient({
    required String patientId,
    required Map<String, dynamic>
    updatedPatientData, // We will pass fields that needs to be updated
  }) async {
    try {
      // We will change our existing given data using 'update' method otherwise 'set' method will write new data
      await _db
          .child(patientId)
          .update(updatedPatientData)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw AppException(
              'Update failed. Please check your internet connection.',
            ),
          );
    } catch (e) {
      throw AppException(ErrorHandler.parse(e));
    }
  }
}
