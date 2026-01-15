// import 'dart:convert';
// import 'dart:io';
// import 'package:Muslim/Core/Const/app_fonts.dart';
// import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/Models/tirmidhi_details_model.dart';
// import 'package:Muslim/Core/Services/ad_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
// import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahmuslim_chapters_model.dart';
// import 'package:path_provider/path_provider.dart';

// class Bukhari extends StatefulWidget {
//   final String title;
//   const Bukhari({super.key, required this.title});

//   @override
//   State<Bukhari> createState() => _BukhariState();
// }

// class _BukhariState extends State<Bukhari> {
//   List<Chapters> chaptersList = [];
//   List<Data> allhadith = [];
//   List<Data> searchedResults = [];

//   bool isLoading = true;
//   bool hasError = false;
//   bool isSearching = false;

//   Future<void> loadofflinechapters() async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });

//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File("${dir.path}/sahih-bukhari.json");

//       if (!file.existsSync()) {
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//         return;
//       }

//       final fileContent = await file.readAsString();
//       final jsonData = jsonDecode(fileContent);

//       // 1️⃣ Load chapters
//       final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
//       chaptersList = chapterData.chapters ?? [];

//       // 2️⃣ Load all Hadiths for search
//       allhadith = [];
//       final chapters = jsonData["chapters"];
//       if (chapters != null && chapters is List) {
//         for (var chapter in chapters) {
//           final hadithMap = chapter["hadiths"];
//           if (hadithMap != null && hadithMap is Map<String, dynamic>) {
//             final hadithList = hadithMap["data"];
//             if (hadithList != null && hadithList is List) {
//               for (var h in hadithList) {
//                 allhadith.add(Data.fromJson(h));
//               }
//             }
//           }
//         }
//       }

//       setState(() {
//         isLoading = false;
//       });

//       print("Chapters loaded: ${chaptersList.length}");
//       print("Total Hadiths loaded: ${allhadith.length}");
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//       print("Error loading offline chapters: $e");
//     }
//   }

//   void searchHadiths(String query) {
//     query = query.trim();
//     List<Data> results = [];

//     if (query.contains('-')) {
//       final parts = query.split('-');
//       final start = int.tryParse(parts[0]);
//       final end = int.tryParse(parts[1]);
//       if (start != null && end != null) {
//         results = allhadith.where((h) {
//           final num = int.tryParse(h.hadithNumber ?? "");
//           return num != null && num >= start && num <= end;
//         }).toList();
//       }
//     } else {
//       final number = int.tryParse(query);
//       if (number != null) {
//         results = allhadith.where((h) {
//           return h.hadithNumber?.toString() == query;
//           // final num = int.tryParse(h.hadithNumber.toString());
//           // return num != null && num == number;
//         }).toList();
//       }
//     }

//     setState(() {
//       searchedResults = results;
//       isSearching = true;
//     });
//   }

//   // void searchHadiths(String query) {
//   //   final number = int.tryParse(query.trim());
//   //   if (number == null) {
//   //     setState(() {
//   //       isSearching = false;
//   //       searchedResults = [];
//   //     });
//   //     return;
//   //   }
//   //   final results = allhadith.where((h) => h.hadithNumber == number).toList();
//   //   setState(() {
//   //     searchedResults = results;
//   //     isSearching = true;
//   //   });
//   // }

//   //here is function to load offline chapterss
//   // Future<void> loadofflinechapters() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     hasError = false;
//   //   });
//   //   try {
//   //     final dir = await getApplicationDocumentsDirectory();
//   //     final file = File("${dir.path}/sahih-bukhari.json");
//   //     if (file.existsSync()) {
//   //       final fileContent = await file.readAsString();
//   //       final jsonData = jsonDecode(fileContent);
//   //       final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
//   //       setState(() {
//   //         chaptersList = chapterData.chapters ?? [];

//   //         print(chaptersList);
//   //         // filturedlist = chaptersList;
//   //         isLoading = false;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         hasError = true;
//   //         isLoading = false;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     hasError = true;
//   //     isLoading = false;
//   //   }
//   // }

//   //list hadiths in evey chapters
//   List<String> hadeesInChapter = [
//     "1-7",
//     "8-58",
//     "59-134",
//     "135-247",
//     "248-293",
//     "294-333",
//     "334-348",
//     "349-520",
//     "521-602",
//     "603-734",
//     "735-875",
//     "876-941",
//     "942-947",
//     "948-989",
//     "990-1004",
//     "1005-1039",
//     "1040-1066",
//     "1067-1079",
//     "1080-1119",
//     "1120-1187",
//     "1188-1197",
//     "1198-1223",
//     "1224-1236",
//     "1237-1394",
//     "1395-1512",
//     "1513-1772",
//     "1773-1805",
//     "1806-1820",
//     "1821-1866",
//     "1867-1890",
//     "1891-2007",
//     "2008-2013",
//     "2014-2024",
//     "2025-2046",
//     "2047-2238",
//     "2239-2256",
//     "2257-2259",
//     "2260-2286",
//     "2287-2289",
//     "2290-2298",
//     "2299-2319",
//     "2320-2350",
//     "2351-2384",
//     "2385-2409",
//     "2410-2425",
//     "2426-2439",
//     "2440-2482",
//     "2483-2507",
//     "2508-2516",
//     "2517-2559",
//     "2560-2565",
//     "2566-2636",
//     "2637-2689",
//     "2690-2710",
//     "2711-2737",
//     "2738-2781",
//     "2782-3090",
//     "3091-3155",
//     "3156-3189",
//     "3190-3325",
//     "3326-3488",
//     "3489-3648",
//     "3649-3775",
//     "3776-3948",
//     "3949-4473",
//     "4474-4977",
//     "4978-5062",
//     "5063-5250",
//     "5251-5350",
//     "5351-5372",
//     "5373-5466",
//     "5467-5474",
//     "5475-5544",
//     "5545-5574",
//     "5575-5639",
//     "5640-5677",
//     "5678-5782",
//     "5783-5969",
//     "5970-6226",
//     "6227-6303",
//     "6304-6411",
//     "6412-6593",
//     "6594-6620",
//     "6621-6707",
//     "6708-6722",
//     "6723-6771",
//     "6772-6801",
//     "6802-6860",
//     "6861-6917",
//     "6918-6939",
//     "6940-6952",
//     "6953-6981",
//     "6982-7047",
//     "7048-7136",
//     "7137-7225",
//     "7226-7245",
//     "7246-7267",
//     "7268-7370",
//     "7371-7563",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     loadofflinechapters();
//   }

//   TextEditingController hadithsearch = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         AdController().tryShowAd();

//         Navigator.pop(context);
//         return false;
//       },

//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,

//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(
//               Icons.arrow_back_ios_new,
//               size: 25,
//               color: Colors.black54,
//             ),
//           ),
//           // title: Text(widget.title),
//           title: TextField(
//             decoration: InputDecoration(
//               hint: Text(
//                 "Search hadith number",
//                 style: TextStyle(color: Colors.black45),
//               ),
//               suffix: IconButton(
//                 onPressed: () {
//                   hadithsearch.clear();
//                   setState(() {
//                     isSearching = false;
//                     searchedResults = [];
//                   });
//                 },
//                 icon: Icon(Icons.close),
//               ),
//             ),

//             controller: hadithsearch,
//             cursorColor: Colors.black,
//             onChanged: searchHadiths,
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//         ),
//         body: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.green),
//               )
//             : hasError
//             ? const Center(child: Text("Error loading chapters"))
//             : isSearching
//             ? searchedResults.isEmpty
//                   ? const Center(child: Text("No Hadith found"))
//                   : ListView.builder(
//                       itemCount: searchedResults.length,
//                       itemBuilder: (context, index) {
//                         final hadith = searchedResults[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => Hadithdetails(
//                                   ChapterId: hadith.chapterId,
//                                   hadithNumber: hadith.hadithNumber,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 3,
//                             margin: const EdgeInsets.all(8),
//                             child: ListTile(
//                               title: Text(
//                                 "Hadith #${hadith.hadithNumber}",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               subtitle: Text(hadith.hadithEnglish ?? ""),
//                             ),
//                           ),
//                         );
//                       },
//                     )
//             : ListView.builder(
//                 itemCount: chaptersList.length,
//                 itemBuilder: (context, index) {
//                   final hadithlength = hadeesInChapter[index];
//                   final chapter = chaptersList[index];
//                   return Card(
//                     elevation: 3,
//                     color: Colors.white,
//                     child: ListTile(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 Hadithdetails(ChapterId: chapter.id.toString()),
//                           ),
//                         );
//                       },
//                       title: Text(
//                         chapter.chapterEnglish ?? "No name",
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       trailing: Text(
//                         hadithlength,
//                         style: TextStyle(
//                           fontFamily: AppFonts.arabicfont,
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahmuslim_chapters_model.dart';
import 'package:path_provider/path_provider.dart';

class Bukhari extends StatefulWidget {
  final String title;
  const Bukhari({super.key, required this.title});

  @override
  State<Bukhari> createState() => _BukhariState();
}

class _BukhariState extends State<Bukhari> {
  List<Chapters> chaptersList = [];

  bool isLoading = true;
  bool hasError = false;
  //here is function to load offline chapterss
  Future<void> loadofflinechapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-bukhari.json");
      if (file.existsSync()) {
        final fileContent = await file.readAsString();
        final jsonData = jsonDecode(fileContent);
        final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
        setState(() {
          chaptersList = chapterData.chapters ?? [];

          print(chaptersList);
          // filturedlist = chaptersList;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      hasError = true;
      isLoading = false;
    }
  }

  //list hadiths in evey chapters
  List<String> hadeesInChapter = [
    "1-7",
    "8-58",
    "59-134",
    "135-247",
    "248-293",
    "294-333",
    "334-348",
    "349-520",
    "521-602",
    "603-734",
    "735-875",
    "876-941",
    "942-947",
    "948-989",
    "990-1004",
    "1005-1039",
    "1040-1066",
    "1067-1079",
    "1080-1119",
    "1120-1187",
    "1188-1197",
    "1198-1223",
    "1224-1236",
    "1237-1394",
    "1395-1512",
    "1513-1772",
    "1773-1805",
    "1806-1820",
    "1821-1866",
    "1867-1890",
    "1891-2007",
    "2008-2013",
    "2014-2024",
    "2025-2046",
    "2047-2238",
    "2239-2256",
    "2257-2259",
    "2260-2286",
    "2287-2289",
    "2290-2298",
    "2299-2319",
    "2320-2350",
    "2351-2384",
    "2385-2409",
    "2410-2425",
    "2426-2439",
    "2440-2482",
    "2483-2507",
    "2508-2516",
    "2517-2559",
    "2560-2565",
    "2566-2636",
    "2637-2689",
    "2690-2710",
    "2711-2737",
    "2738-2781",
    "2782-3090",
    "3091-3155",
    "3156-3189",
    "3190-3325",
    "3326-3488",
    "3489-3648",
    "3649-3775",
    "3776-3948",
    "3949-4473",
    "4474-4977",
    "4978-5062",
    "5063-5250",
    "5251-5350",
    "5351-5372",
    "5373-5466",
    "5467-5474",
    "5475-5544",
    "5545-5574",
    "5575-5639",
    "5640-5677",
    "5678-5782",
    "5783-5969",
    "5970-6226",
    "6227-6303",
    "6304-6411",
    "6412-6593",
    "6594-6620",
    "6621-6707",
    "6708-6722",
    "6723-6771",
    "6772-6801",
    "6802-6860",
    "6861-6917",
    "6918-6939",
    "6940-6952",
    "6953-6981",
    "6982-7047",
    "7048-7136",
    "7137-7225",
    "7226-7245",
    "7246-7267",
    "7268-7370",
    "7371-7563",
  ];

  @override
  void initState() {
    super.initState();
    loadofflinechapters();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AdController().tryShowAd();
        Navigator.pop(context);
        return false;
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [],

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 25,
              color: Colors.black54,
            ),
          ),
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("Error loading chapters"))
            : chaptersList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chaptersList.length,
                itemBuilder: (context, index) {
                  final hadithlength = hadeesInChapter[index];
                  final chapter = chaptersList[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Hadithdetails(ChapterId: chapter.id.toString()),
                          ),
                        );
                      },
                      title: Text(
                        chapter.chapterEnglish ?? "No name",
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: Text(
                        hadithlength,
                        style: TextStyle(
                          fontFamily: AppFonts.arabicfont,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
