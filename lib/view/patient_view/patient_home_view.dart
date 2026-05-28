import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/view/nurse_view/all_nurses_view.dart';
import 'package:project_uaf/view/nurse_view/nurse_detail_view.dart';
import 'package:project_uaf/view/nurse_view/widgets/nurse_card.dart';
import 'package:project_uaf/view/patient_view/widgets/nurse_search_bar.dart';
import 'package:project_uaf/view/patient_view/widgets/patient_header.dart';
import '../../model/nurse_model.dart';
import '../../model/patient_model.dart';
import '../../resources/utils/states.dart';
import '../../services/nurse_service.dart';
import '../../services/patient_service.dart';

class PatientHomeView extends StatefulWidget {
  final String patientId;
  const PatientHomeView({super.key, required this.patientId});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  //--Service Classes instances---
  final NurseService _nurseService = NurseService();
  final PatientService _patientService = PatientService();
  // Loading indicator for whole screen
  PageState _pageState = PageState.loading;
  // Loading indicator for nurse listview
  NurseListState _nurseListState = NurseListState.loading;
  // variable to store error messages
  String _errorMessage = '';
  // controller for search bar
  final SearchController _searchController = SearchController();
  //---State Variables---
  // --- Now we create a variable of the type 'PatientModel'
  // because it will help us fetch data of the patient through 'PatientModel'
  PatientModel? _patient;
  List<NurseModel> _allNurses =
      []; // Original nurse list containing un-filtered data
  List<NurseModel> _filteredNurses = [];

  String _searchQuery = '';
  String _selectedGender = 'All';
  String _selectedAvailability = 'All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  // Making a load data method which calls both patient and nurse service class using Future.wait
  // Which is much faster then calling them one after another
  Future<void> _loadData() async {
    // Reset state to loading when retrying
    setState(() {
      _pageState = PageState.loading;
    });
    // print('_loadData started');
    try {
      final results =
          await Future.wait([
            _patientService.fetchPatient(widget.patientId),
            _nurseService.fetchNurses(),
          ]).timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw AppException(
              'Connection timed out. \nPlease check your connection & try again.',
            ),
          );
      // print('fetch completed');
      // print('patient: ${results[0]}'); // is patient null?
      // print('nurses count: ${(results[1] as List).length}');
      final nurses = results[1] as List<NurseModel>;
      setState(() {
        _patient = results[0] as PatientModel?;
        _allNurses = nurses;
        _filteredNurses = _allNurses; // show all nurses by default
        // Screen loaded fine
        _pageState = PageState.success;
        // If nurses are available then populate the listview after filtering - if not then show it is empty
        _nurseListState = nurses.isEmpty
            ? NurseListState.empty
            : NurseListState.populated;
      });
      // print('pageState is now: $_pageState');
    } on AppException catch (e) {
      // print('AppException: ${e.message}');
      setState(() {
        _errorMessage = e.message;
        _pageState = PageState.error;
      });
    } catch (e) {
      // print('Unknown error: $e');
      setState(() {
        _errorMessage = e.toString();
        _pageState = PageState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_pageState) {
      PageState.loading => Center(
        child: SpinKitFadingCircle(color: AppColors.blueColor, size: 50),
      ),
      PageState.error => GeneralExceptionWidget(
        onPress: _loadData,
        message: _errorMessage,
      ),
      PageState.success => _buildHomeContent(),
    };
  }

  Widget _buildHomeContent() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.all(22.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            PatientHeader(patient: _patient!),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: NurseSearchBar(
                controller: _searchController,
                onClear: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                },
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),
            SizedBox(height: 16.h),
            _buildNurseSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNurseSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Nurses', style: Theme.of(context).textTheme.bodyMedium),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllNursesView(nurses: _allNurses),
                  ),
                ),
                child: Text(
                  'See All',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.blueColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildFilterChips(),
          SizedBox(height: 12.h),

          // Switch on NurseListState here
          Expanded(
            child: switch (_nurseListState) {
              NurseListState.loading => SpinKitFadingCircle(
                color: AppColors.blueColor,
              ),

              NurseListState.empty => Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60.r,
                      color: AppColors.greyColor,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No nurses found',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),

              NurseListState.populated => RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.separated(
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NurseDetailView(nurse: _filteredNurses[index]),
                        ),
                      );
                    },
                    child: NurseCard(nurse: _filteredNurses[index]),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: _filteredNurses.length,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  // Function for filtering Nurse data
  void _applyFilters() {
    setState(() {
      _filteredNurses = _allNurses.where((nurse) {
        // Check 1: Search bar match
        // if _searchQuery is empty then every nurse passes isEmpty check and every nurse will be shown
        // Or, every nurse's name must contain the typed text in the search bar (case-insensitive)
        final nameMatch =
            _searchQuery.isEmpty ||
            nurse.firstName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            _searchQuery.isEmpty ||
            nurse.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            _searchQuery.isEmpty ||
            nurse.city.toLowerCase().contains(_searchQuery.toLowerCase());

        // Check 2: Gender chip match
        // If 'All' choice-chip is selected or clicked, then all nurses will appear in 'All' section,
        // Otherwise _nurse.gender will pass gender related data and that data will appear in 'Male or Female' choice chip
        final genderMatch =
            _selectedGender == 'All' ||
            nurse.gender.toLowerCase() == _selectedGender.toLowerCase();

        // Check 3: Availability chip match
        // If 'All' choice-chip is selected or clicked, then all nurses will appear in 'All' section
        // Otherwise _nurse.availability will pass availability related data and tat data will be divided into 'Full-time, Half-time' choice chips
        final availabilityMatch =
            _selectedAvailability == 'All' ||
            nurse.availability.toLowerCase() ==
                _selectedAvailability.toLowerCase();

        // A nurse only appears if she/he passes all above three checks
        return nameMatch &&
            genderMatch &&
            availabilityMatch;
      }).toList();
      // Update nurse list state after every filter change
      _nurseListState = _filteredNurses.isEmpty
          ? NurseListState.empty
          : NurseListState.populated;
    });
  }

  // Making choice chips row
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // First Gender Chips
          for (final gender in ['All', 'Female', 'Male'])
            Padding(
              padding: EdgeInsets.only(right: 8.r),
              child: ChoiceChip(
                label: Text(gender),
                selected: _selectedGender == gender,
                labelStyle: TextStyle(
                  color: _selectedGender == gender ? Colors.white : Colors.blue,
                  fontFamily: 'Poppins',
                  fontWeight: _selectedGender == gender
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                  side: BorderSide(
                    color: _selectedGender == gender
                        ? AppColors.blueColor
                        : AppColors.blueColor, // Border color
                    width: 1.0,
                  ),
                ),
                showCheckmark: false,
                selectedColor: AppColors.blueColor,
                backgroundColor: AppColors.whiteColor,

                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedGender = gender;
                    });
                    _applyFilters();
                  }
                },
              ),
            ),
          SizedBox(width: 8.w),
          Container(width: 1.w, height: 24.h, color: Colors.grey.shade300),
          SizedBox(width: 8.w),

          // Second Availability chips
          for (final availability in ['All', 'Full-Time', 'Part-Time'])
            Padding(
              padding: EdgeInsets.only(right: 8.r),
              child: ChoiceChip(
                selectedColor: AppColors.blueColor,
                backgroundColor: AppColors.whiteColor,
                showCheckmark: false,
                label: Text(availability),
                selected: _selectedAvailability == availability,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: _selectedAvailability == availability
                      ? AppColors.whiteColor
                      : AppColors.blueColor,
                  fontWeight: _selectedAvailability == availability
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                  side: BorderSide(
                    color: _selectedAvailability == availability
                        ? AppColors.blueColor
                        : AppColors.blueColor, // Border color
                    width: 1.0,
                  ),
                ),

                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedAvailability = availability;
                    });
                    _applyFilters();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
