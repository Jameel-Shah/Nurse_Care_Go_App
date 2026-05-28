import 'package:flutter/material.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/view/patient_view/booking_history_screen.dart';
import 'package:project_uaf/view/patient_view/patient_chat_list_view.dart';
import 'package:project_uaf/view/patient_view/patient_home_view.dart';
import 'package:project_uaf/view/patient_view/patient_profile_view.dart';

class PatientNavigationBar extends StatefulWidget {
  final String patientId;
  const PatientNavigationBar({super.key, required this.patientId});

  @override
  State<PatientNavigationBar> createState() => _PatientNavigationBarState();
}

class _PatientNavigationBarState extends State<PatientNavigationBar> {
  //Initializing an index which makes sure which item is selected first
  int _selectedIndex = 0; // 0 means nurse home screen will be selected by default
  // Creating a list of screens
  late final List<Widget> _patientScreens;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Calling the list in initState. So, it can be displayed first
    _patientScreens=[
      PatientHomeView(patientId: widget.patientId,),
      BookingHistoryScreen(patientId: widget.patientId),
      PatientChatListView(),
      PatientProfileView(patientId: widget.patientId,)
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _patientScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home',),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat',),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
      ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.blueColor,
        selectedItemColor: AppColors.whiteColor ,
        unselectedItemColor:  AppColors.whiteColor60,
        onTap: (index){
        setState(() {
          _selectedIndex=index;
        });
        },
        currentIndex: _selectedIndex,
      ),



    );
  }
}
