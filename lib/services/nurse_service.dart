import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';

class NurseService {
  // Reference path to 'Nurses' database
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('Nurses');
  // Method for fetching nurses data as a list or the whole data from nurses node/folder/database
  Future<List<NurseModel>> fetchNurses() async {
    // .once() will read the entire nurse database at one time
    // event.snapShot will keep a Map of all nurses
    final event = await _db.once();
    final snapShot = event.snapshot;
    // Creating an empty list to store/pass the fetched data
    List<NurseModel> nurses = [];
    // snapShot.value is the actual data, we now check if it is null or not
    if (snapShot.value != null) {
      // The entire nurses data comes back as a Map
      // Each entry is like key: "nurse1" , value{firstName, gender,..}
      final values = snapShot.value as Map<dynamic, dynamic>;
      // .forEach loops through all the data in the nurse database
      // key is Firebase's auto generated id
      // value is nurse's map field data
      values.forEach((key, value) {
        // value is still dynamic - we cast it into the map
        // key becomes nurse's id in the model
        // Also add the data into the empty nurses list
        nurses.add(NurseModel.fromMap(value, key));
      });
    }
    return nurses; // Returns the list
  }

  // Method fr fetching nurse data by id or single nurse
  Future<NurseModel?> fetchNurseById(String nurseId) async {
    // .child(nurseId) means that going inside deep into 'Nurses' database
    // .once() reads data inside database one time and stops
    // It returns a DatabaseEvent object
    final event = await _db
        .child(nurseId)
        .once()
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw AppException(
            'Something went wrong, check your internet connection and try again',
          ),
        );
    // DatabaseEvent object contains a snapShot
    // snapShot acts a Firebase wrapper around raw data
    // It contains vale & key(uid)
    final snapShot = event.snapshot;
    // snapShot.value is the actual data but it comes as dynamic - unknown type
    // First, we check if it has any data or it is just null like no data inside 'Nurses' database
    if (snapShot.value != null) {
      // If data exists, then cast it to map so, we can read data as map['firstName']
      // Also, passing the nurseId
      return NurseModel.fromMap(
        snapShot.value as Map<dynamic, dynamic>,
        nurseId,
      );
    }
    return null;
  }

  // Now we write a method to update nurses data
  Future<void> updateNurse({
    required String nurseId,
    required Map<String, dynamic> updatedNurseData,
  }) async {
    try {
      // We update by using Firebase's update method by id
      await _db
          .child(nurseId)
          .update(updatedNurseData)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw AppException(
              'Update failed. Please check your internet connection.',
            ),
          );
    } catch (e) {
      // We re-throw as AppException so the UI gets a clean, readable message
      throw AppException(ErrorHandler.parse(e));
    }
  }
}
