// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:gap/gap.dart';
// // import 'package:path_provider/path_provider.dart';
// // // Apne model ka path confirm kar lena
// // import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

// // class SearchAhadees extends StatefulWidget {
// //   const SearchAhadees({super.key});

// //   @override
// //   State<SearchAhadees> createState() => _SearchAhadeesState();
// // }

// // class _SearchAhadeesState extends State<SearchAhadees> {
// //   final TextEditingController _searchController = TextEditingController();
// //   List<Data> allHadithsList = [];
// //   List<Data> searchResults = [];
// //   bool isLoading = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     loadAllBooksData();
// //   }

// //   // --- DATA LOADING LOGIC ---
// //   Future<void> loadAllBooksData() async {
// //     if (!mounted) return;
// //     setState(() => isLoading = true);

// //     // Ye slugs DownloadService ke exact match hain
// //     List<String> slugs = [
// //       "sahih-bukhari",
// //       "sahih-muslim",
// //       "al-tirmidhi",
// //       "abu-dawood",
// //       "ibn-e-majah",
// //       "sunan-nasai",
// //     ];

// //     try {
// //       final dir = await getApplicationDocumentsDirectory();
// //       List<Data> tempAllHadiths = [];

// //       for (String slug in slugs) {
// //         final file = File("${dir.path}/$slug.json");

// //         if (file.existsSync()) {
// //           final content = await file.readAsString();
// //           final dynamic decoded = jsonDecode(content);

// //           // 1. Check: Agar chapters -> hadiths -> data wala format hai
// //           if (decoded is Map && decoded.containsKey("chapters")) {
// //             var chapters = decoded["chapters"];
// //             if (chapters is List) {
// //               for (var chapter in chapters) {
// //                 var hData = chapter["hadiths"]?["data"];
// //                 if (hData is List) {
// //                   for (var h in hData) {
// //                     tempAllHadiths.add(Data.fromJson(h));
// //                   }
// //                 }
// //               }
// //             }
// //           }
// //           // 2. Check: Agar direct "data" key ke andar list hai
// //           else if (decoded is Map && decoded.containsKey("data")) {
// //             var dataList = decoded["data"];
// //             if (dataList is List) {
// //               for (var d in dataList) {
// //                 tempAllHadiths.add(Data.fromJson(d));
// //               }
// //             }
// //           }
// //           // 3. Check: Agar file direct ek List hai
// //           else if (decoded is List) {
// //             for (var item in decoded) {
// //               tempAllHadiths.add(Data.fromJson(item));
// //             }
// //           }
// //         } else {
// //           print("⚠️ File missing: $slug.json");
// //         }
// //       }

// //       if (mounted) {
// //         setState(() {
// //           allHadithsList = tempAllHadiths;
// //           isLoading = false;
// //         });
// //       }
// //       print("✅ Total Data Loaded: ${allHadithsList.length}");
// //     } catch (e) {
// //       print("❌ Error: $e");
// //       if (mounted) setState(() => isLoading = false);
// //     }
// //   }

// //   // --- SEARCH FILTER ---
// //   void _runFilter(String query) {
// //     List<Data> results = [];
// //     if (query.isEmpty) {
// //       results = [];
// //     } else {
// //       results = allHadithsList.where((hadith) {
// //         final hNumber = hadith.hadithNumber.toString();
// //         final hUrdu = (hadith.hadithUrdu ?? "").toLowerCase();
// //         // Dono number aur text search support karega
// //         return hNumber.contains(query) || hUrdu.contains(query.toLowerCase());
// //       }).toList();
// //     }

// //     setState(() {
// //       searchResults = results;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F5F5),
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         leading: IconButton(
// //           onPressed: () => Navigator.pop(context),
// //           icon: const Icon(Icons.arrow_back_ios_new),
// //         ),
// //         title: Text(
// //           "Search (${allHadithsList.length} Hadiths)",
// //           style: const TextStyle(color: Colors.black, fontSize: 16),
// //         ),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //       ),
// //       body: Column(
// //         children: [
// //           // Search Field
// //           Container(
// //             color: Colors.white,
// //             padding: const EdgeInsets.all(15.0),
// //             child: TextField(
// //               controller: _searchController,
// //               onChanged: _runFilter,
// //               keyboardType: TextInputType.number,
// //               decoration: InputDecoration(
// //                 hintText: "Enter Hadith Number...",
// //                 prefixIcon: const Icon(Icons.search, color: Colors.green),
// //                 filled: true,
// //                 fillColor: Colors.grey.shade100,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(15),
// //                   borderSide: BorderSide.none,
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Results
// //           Expanded(
// //             child: isLoading
// //                 ? const Center(
// //                     child: CircularProgressIndicator(color: Colors.green),
// //                   )
// //                 : _searchController.text.isEmpty
// //                 ? const Center(child: Text("Start searching..."))
// //                 : searchResults.isEmpty
// //                 ? const Center(child: Text("No Hadith found"))
// //                 : ListView.builder(
// //                     itemCount: searchResults.length,
// //                     itemBuilder: (context, index) {
// //                       final hadith = searchResults[index];
// //                       return HadithCardWidget(hadith: hadith);
// //                     },
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // --- CARD WIDGET ---
// // class HadithCardWidget extends StatelessWidget {
// //   final Data hadith;
// //   const HadithCardWidget({super.key, required this.hadith});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       color: Colors.white,
// //       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //       child: ExpansionTile(
// //         leading: CircleAvatar(
// //           backgroundColor: Colors.green,
// //           child: Text(
// //             hadith.hadithNumber.toString(),
// //             style: const TextStyle(color: Colors.white, fontSize: 10),
// //           ),
// //         ),
// //         title: Text(
// //           hadith.hadithArabic ?? "",
// //           textAlign: TextAlign.right,
// //           maxLines: 1,
// //           style: const TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         subtitle: Text(
// //           hadith.hadithUrdu ?? "",
// //           textAlign: TextAlign.right,
// //           maxLines: 1,
// //           style: const TextStyle(color: Colors.green, fontSize: 12),
// //         ),
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(15.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 Text(
// //                   hadith.hadithArabic ?? "",
// //                   textAlign: TextAlign.right,
// //                   style: const TextStyle(fontSize: 20),
// //                 ),
// //                 const Divider(),
// //                 Text(
// //                   hadith.hadithUrdu ?? "",
// //                   textAlign: TextAlign.right,
// //                   style: const TextStyle(fontSize: 16),
// //                 ),
// //                 if (hadith.hadithEnglish != null) ...[
// //                   const Gap(10),
// //                   Text(
// //                     hadith.hadithEnglish!,
// //                     style: const TextStyle(color: Colors.grey),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:path_provider/path_provider.dart';
// // Model ka path confirm kar lena
// import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

// class SearchAhadees extends StatefulWidget {
//   const SearchAhadees({super.key});

//   @override
//   State<SearchAhadees> createState() => _SearchAhadeesState();
// }

// class _SearchAhadeesState extends State<SearchAhadees> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Data> allHadithsList = [];
//   List<Data> searchResults = [];
//   bool isLoading = false;

//   // Ye map track karega ke kaunsi kitab load hui
//   Map<String, bool> bookStatus = {
//     "sahih-bukhari": false,
//     "sahih-muslim": false,
//     "al-tirmidhi": false,
//     "abu-dawood": false,
//     "ibn-e-majah": false,
//     "sunan-nasai": false,
//   };

//   @override
//   void initState() {
//     super.initState();
//     loadAllBooksData();
//   }

//   Future<void> loadAllBooksData() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);

//     final dir = await getApplicationDocumentsDirectory();
//     List<Data> tempAllHadiths = [];

//     // Keys wahi hain jo DownloadService mein hain
//     for (String slug in bookStatus.keys.toList()) {
//       final file = File("${dir.path}/$slug.json");

//       if (file.existsSync()) {
//         try {
//           final content = await file.readAsString();
//           final dynamic decoded = jsonDecode(content);

//           int initialCount = tempAllHadiths.length;

//           // --- HAR KISIM KA JSON STRUCTURE HANDLE KARNE KE LIYE ---
//           if (decoded is Map && decoded.containsKey("chapters")) {
//             for (var chapter in decoded["chapters"]) {
//               var hData = chapter["hadiths"]?["data"];
//               if (hData is List) {
//                 tempAllHadiths.addAll(
//                   hData.map((e) => Data.fromJson(e)).toList(),
//                 );
//               }
//             }
//           } else if (decoded is Map && decoded.containsKey("data")) {
//             var dataList = decoded["data"];
//             if (dataList is List) {
//               tempAllHadiths.addAll(
//                 dataList.map((e) => Data.fromJson(e)).toList(),
//               );
//             }
//           } else if (decoded is List) {
//             tempAllHadiths.addAll(
//               decoded.map((e) => Data.fromJson(e)).toList(),
//             );
//           }

//           // Agar data add hua hai toh status true kar do
//           if (tempAllHadiths.length > initialCount) {
//             bookStatus[slug] = true;
//           }
//         } catch (e) {
//           print("Error parsing $slug: $e");
//         }
//       }
//     }

//     if (mounted) {
//       setState(() {
//         allHadithsList = tempAllHadiths;
//         isLoading = false;
//       });
//     }
//   }

//   void _runFilter(String query) {
//     if (query.isEmpty) {
//       setState(() => searchResults = []);
//       return;
//     }

//     final results = allHadithsList.where((hadith) {
//       final hNum = hadith.hadithNumber.toString();
//       final hUrdu = (hadith.hadithUrdu ?? "").toLowerCase();
//       return hNum.contains(query) || hUrdu.contains(query.toLowerCase());
//     }).toList();

//     setState(() => searchResults = results);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios_new),
//         ),
//         title: Text("Universal Search (${allHadithsList.length})"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Search Input
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _runFilter,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Search Hadith Number...",
//                 prefixIcon: const Icon(Icons.search, color: Colors.green),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),

//           // --- BOOK STATUS INDICATOR ---
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: bookStatus.entries.map((entry) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 6,
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     color: entry.value
//                         ? Colors.green.withOpacity(0.1)
//                         : Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: entry.value ? Colors.green : Colors.red,
//                       width: 0.5,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       "${entry.key.replaceAll('-', ' ')} ${entry.value ? '✅' : '❌'}",
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: entry.value ? Colors.green : Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           const Divider(height: 1),

//           // Results Section
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.green),
//                   )
//                 : _searchController.text.isEmpty
//                 ? const Center(
//                     child: Text("Type any number (e.g. 7563 for Bukhari Last)"),
//                   )
//                 : searchResults.isEmpty
//                 ? const Center(child: Text("No Results Found"))
//                 : ListView.builder(
//                     itemCount: searchResults.length,
//                     itemBuilder: (context, index) =>
//                         HadithTile(hadith: searchResults[index]),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HadithTile extends StatelessWidget {
//   final Data hadith;
//   const HadithTile({super.key, required this.hadith});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.green,
//           child: Text(
//             hadith.hadithNumber.toString(),
//             style: const TextStyle(color: Colors.white, fontSize: 10),
//           ),
//         ),
//         title: Text(
//           hadith.hadithArabic ?? "",
//           textAlign: TextAlign.right,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Text(
//           hadith.hadithUrdu ?? "",
//           textAlign: TextAlign.right,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(color: Colors.green, fontSize: 12),
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   hadith.hadithArabic ?? "",
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Divider(),
//                 Text(
//                   hadith.hadithUrdu ?? "",
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 if (hadith.hadithEnglish != null) ...[
//                   const Gap(10),
//                   Text(
//                     hadith.hadithEnglish!,
//                     style: const TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // compute function ke liye
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
// Model ka path confirm kar lein
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> allHadithsList = [];
  List<Data> searchResults = [];
  bool isLoading = false;

  Map<String, bool> bookStatus = {
    "sahih-bukhari": false,
    "sahih-muslim": false,
    "al-tirmidhi": false,
    "abu-dawood": false,
    "ibn-e-majah": false,
    "sunan-nasai": false,
  };

  @override
  void initState() {
    super.initState();
    loadAllBooksData();
  }

  // --- OPTIMIZED LOADING LOGIC ---
  Future<void> loadAllBooksData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final dir = await getApplicationDocumentsDirectory();
    List<Data> tempAllHadiths = [];

    for (String slug in bookStatus.keys.toList()) {
      final file = File("${dir.path}/$slug.json");

      if (file.existsSync()) {
        try {
          final String content = await file.readAsString();

          // Bari files ko 'compute' ke zariye background thread par parse karein
          // Isse UI freeze nahi hoga (Choreographer skipped frames error khatam hoga)
          final List<Data> parsedData = await compute(_parseJson, content);

          if (parsedData.isNotEmpty) {
            tempAllHadiths.addAll(parsedData);
            bookStatus[slug] = true;
          }
        } catch (e) {
          debugPrint("❌ Error parsing $slug: $e");
        }
      }
    }

    if (mounted) {
      setState(() {
        allHadithsList = tempAllHadiths;
        isLoading = false;
      });
    }
  }

  // Background thread par chalne wala function
  static List<Data> _parseJson(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    List<Data> list = [];

    if (decoded is Map && decoded.containsKey("chapters")) {
      for (var chapter in decoded["chapters"]) {
        var hData = chapter["hadiths"]?["data"];
        if (hData is List) {
          list.addAll(hData.map((e) => Data.fromJson(e)).toList());
        }
      }
    } else if (decoded is Map && decoded.containsKey("data")) {
      var dataList = decoded["data"];
      if (dataList is List) {
        list.addAll(dataList.map((e) => Data.fromJson(e)).toList());
      }
    } else if (decoded is List) {
      list.addAll(decoded.map((e) => Data.fromJson(e)).toList());
    }
    return list;
  }

  // --- SEARCH LOGIC ---
  void _runFilter(String query) {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    // Sirf top 100 results dikhayein taake UI lag na kare
    final results = allHadithsList
        .where((hadith) {
          final hNum = hadith.hadithNumber.toString();
          return hNum.contains(query);
        })
        .take(100)
        .toList();

    setState(() => searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Search (${allHadithsList.length})",
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Hadith Number...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Status Badges
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: bookStatus.entries
                  .map((e) => _buildBadge(e.key, e.value))
                  .toList(),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text("No Results Found"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    // Performance boost ke liye itemExtent ya fixedExtent use karein
                    itemBuilder: (context, index) => HadithTile(
                      hadith: searchResults[index],
                      key: ValueKey(searchResults[index].hadithNumber),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String name, bool exists) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: exists
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: exists ? Colors.green : Colors.red),
      ),
      child: Center(
        child: Text(
          name.split('-').last.toUpperCase() + (exists ? " ✅" : " ❌"),
          style: TextStyle(
            color: exists ? Colors.green : Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HadithTile extends StatelessWidget {
  final Data hadith;
  const HadithTile({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(
            hadith.hadithNumber.toString(),
            style: const TextStyle(fontSize: 10),
          ),
        ),
        title: Text(
          hadith.hadithArabic ?? "",
          textAlign: TextAlign.right,
          maxLines: 1,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(hadith.hadithUrdu ?? "", textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
