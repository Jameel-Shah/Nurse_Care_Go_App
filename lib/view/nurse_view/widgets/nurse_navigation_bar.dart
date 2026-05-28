import 'package:flutter/material.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/view/nurse_view/nurse_chat_list_view.dart';
import 'package:project_uaf/view/nurse_view/nurse_home_view.dart';
import 'package:project_uaf/view/nurse_view/nurse_profile_view.dart';

class NurseNavigationBar extends StatefulWidget {
  final String nurseId;
  const NurseNavigationBar({super.key, required this.nurseId});

  @override
  State<NurseNavigationBar> createState() => _NurseNavigationBarState();
}

class _NurseNavigationBarState extends State<NurseNavigationBar> {
  //Initializing an index which makes sure which item is selected first
  int _selectedIndex = 0; // 0 means nurse home screen will be selected by default
  // Creating a list of screens
  late final List<Widget> _nurseScreens;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nurseScreens=[
      NurseHomeView(nurseId: widget.nurseId,),
      NurseChatListView(),
      NurseProfileView(nurseId: widget.nurseId,),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _nurseScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home',),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat',),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
      ],
        backgroundColor: AppColors.blueColor,
        selectedItemColor: AppColors.whiteColor,
        unselectedItemColor: AppColors.whiteColor60,
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
