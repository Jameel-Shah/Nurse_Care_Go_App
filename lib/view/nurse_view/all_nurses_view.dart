import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/services/nurse_service.dart';
import 'package:project_uaf/view/nurse_view/nurse_detail_view.dart';
import 'package:project_uaf/view/nurse_view/widgets/nurse_card.dart';
import 'package:project_uaf/view/patient_view/widgets/nurse_search_bar.dart';
import '../../model/nurse_model.dart';
import '../../resources/colors/colors.dart';

class AllNursesView extends StatefulWidget {
  final List<NurseModel> nurses;
  const AllNursesView({super.key, required this.nurses});

  @override
  State<AllNursesView> createState() => _AllNursesViewState();
}

class _AllNursesViewState extends State<AllNursesView> {
  late List<NurseModel> _allNurses; // We added this as a local copy
  late List<NurseModel> _filteredNurses;
  String _searchQuery = '';
  String _selectedGender = 'All';
  String _selectedAvailability = 'All';
  // controller for search bar
  final SearchController _searchController = SearchController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _allNurses = widget
        .nurses; // We copy all the data from the parent widget and store it inside '_allNurses'
    _filteredNurses = widget.nurses;
  }

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
        return nameMatch && genderMatch && availabilityMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Nurses',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(22.r),
        child: Column(
          children: [
            NurseSearchBar(
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
            SizedBox(height: 12.h),
            _buildFilterChips(),
            SizedBox(height: 12.h),
            Expanded(
              child: RefreshIndicator(
                // We cannot call 'Firebase' here because this screen list as a parameter and list has data
                // So instead notify user can go back to home screen and pull refresh on home screen or fetch fresh data from 'Firebase' here.
                // For simplicity, we can fetch fresh data here
                onRefresh: () async {
                  final freshNurses = await NurseService().fetchNurses();
                  setState(() {
                    // update the list
                    _allNurses = freshNurses; // update local source
                    // _filteredNurses = freshNurses; // reset display list
                  });
                  _applyFilters();
                },
                child: _filteredNurses.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: 200),
                          Center(
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
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: AppColors.greyColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NurseDetailView(
                                  nurse: _filteredNurses[index],
                                ),
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
            ),
          ],
        ),
      ),
    );
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
