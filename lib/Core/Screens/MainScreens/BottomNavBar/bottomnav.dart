// import 'package:flutter/material.dart';
// import 'package:muslim/Core/Const/app_images.dart';
// import 'package:muslim/Core/Screens/MainScreens/Quran_e_Majeed.dart';
// import 'package:muslim/Core/Screens/MainScreens/ahadees.dart';
// import 'package:muslim/Core/Screens/MainScreens/tasbeeh.dart';

// class Bottomnav extends StatefulWidget {
//   const Bottomnav({super.key});

//   @override
//   State<Bottomnav> createState() => _BottomnavState();
// }

// class _BottomnavState extends State<Bottomnav> {
//   // Screens in bottom nav (Quran & Ahadees only, Tasbeeh will be opened separately)
//   List<Widget> screens = [QuranEMajeed(), Ahadees()];
//   int selectedindex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Show current screen
//       body: screens[selectedindex],

//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedindex,
//         backgroundColor: Colors.green,
//         selectedItemColor: Colors.amber,
//         unselectedItemColor: Colors.white,
//         type: BottomNavigationBarType.fixed,

//         // Handle taps
//         onTap: (index) {
//           if (index == 1) {
//             // ✅ If user taps Tasbeeh, open full screen without bottom bar
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const Tasbeeh()),
//             );
//           } else {
//             // ✅ Otherwise switch tab (Quran / Hadees)
//             setState(() {
//               // selectedindex = index == 0 ? 0 : 1;
//               selectedindex = index == 0 ? 0 : 1;
//             });
//           }
//         },

//         items: [
//           // Quran Tab
//           BottomNavigationBarItem(
//             icon: SizedBox(
//               height: 30,
//               width: 30,
//               child: ImageIcon(AssetImage(AppImages.book)),
//             ),
//             label: "Quran",
//           ),

//           // Tasbeeh Tab (opens separately, not part of screens list)
//           BottomNavigationBarItem(
//             icon: SizedBox(
//               height: 30,
//               width: 30,
//               child: ImageIcon(AssetImage(AppImages.tasbeeh0)),
//             ),
//             label: "Tasbeeh",
//           ),

//           // Ahadees Tab
//           BottomNavigationBarItem(
//             icon: SizedBox(
//               height: 30,
//               width: 30,
//               child: ImageIcon(AssetImage(AppImages.bookss)),
//             ),
//             label: "Hadees",
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:muslim/Core/Screens/MainScreens/Quran/Quran_e_Majeed.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/ahadees.dart';
import 'package:muslim/Core/Screens/MainScreens/Tasbeeh/tasbeeh.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  // Screens in bottom nav (Quran & Ahadees only, Tasbeeh will be opened separately)
  List<Widget> screens = [QuranEMajeed(), Ahadees()];
  int selectedindex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show current screen
      body: screens[selectedindex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedindex == 1 ? 2 : selectedindex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        elevation: 10,

        // Handle taps
        onTap: (index) {
          if (index == 1) {
            // ✅ If user taps Tasbeeh, open full screen without bottom bar
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Tasbeeh()),
            );
          } else if (index == 0) {
            // ✅ Quran tab
            setState(() {
              selectedindex = 0;
            });
          } else if (index == 2) {
            // ✅ Hadees tab
            setState(() {
              selectedindex = 1;
            });
          }
        },

        items: [
          // Quran Tab
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              width: 25,
              child: ImageIcon(AssetImage(AppImages.book)),
            ),
            label: "Quran",
          ),

          // Tasbeeh Tab (opens separately, not part of screens list)
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              width: 25,
              child: ImageIcon(AssetImage(AppImages.tasbeeh0)),
            ),
            label: "Tasbeeh",
          ),

          // Ahadees Tab
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              width: 25,
              child: ImageIcon(AssetImage(AppImages.bookss)),
            ),
            label: "Hadees",
          ),
        ],
      ),
    );
  }
}
