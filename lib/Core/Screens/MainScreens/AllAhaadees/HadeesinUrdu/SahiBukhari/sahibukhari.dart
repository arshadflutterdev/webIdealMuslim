import 'dart:convert';
import 'dart:io';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadithDetails.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahmuslim_chapters_model.dart';

class BukhariUrdu extends StatefulWidget {
  final String title;
  const BukhariUrdu({super.key, required this.title});

  @override
  State<BukhariUrdu> createState() => _BukhariUrduState();
}

class _BukhariUrduState extends State<BukhariUrdu> {
  List<Chapters> chaptersList = [];
  List<Chapters> filteredlist = [];
  bool isLoading = true;
  bool hasError = false;
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
          filteredlist = chaptersList;
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

  final TextEditingController _searchcontroller = TextEditingController();
  Future chaptersearching(String query) async {
    setState(() {
      filteredlist = chaptersList.where((Chapters) {
        final name = Chapters.chapterUrdu?.toString().toLowerCase() ?? '';
        final number = Chapters.chapterNumber?.toString().toLowerCase() ?? "";
        final input = query.toLowerCase();
        return name.contains(input) || number.contains(input);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // loadChapters();
  }

  /// Load from SharedPreferences first, then API if not cached
  // Future<void> loadChapters() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? cachedData = prefs.getString('bukhari_chapters');

  //     if (cachedData != null) {
  //       // ✅ Load cached chapters
  //       final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
  //       final localChapters = Sahimuslimchapterlist.fromJson(jsonMap);
  //       setState(() {
  //         chaptersList = localChapters.chapters ?? [];
  //         filteredlist = chaptersList;
  //         isLoading = false;
  //       });
  //     } else {
  //       // ✅ First time → fetch from API and save
  //       await fetchAndCacheChapters();
  //     }
  //   } catch (e) {
  //     setState(() {
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  /// Fetch from API and store in SharedPreferences
  // Future<void> fetchAndCacheChapters() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         "https://hadithapi.com/api/sahih-bukhari/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //       final chaptersData = Sahimuslimchapterlist.fromJson(jsonData);

  //       // ✅ Save full JSON in SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('bukhari_chapters', jsonEncode(jsonData));

  //       setState(() {
  //         chaptersList = chaptersData.chapters ?? [];
  //         filteredlist = chaptersList;
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         hasError = true;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: ContinuousRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,

                        title: Column(
                          children: [
                            Text(
                              "Search Chapter",
                              style: TextStyle(fontSize: 20),
                            ),
                            Gap(15),

                            CustomTextField(
                              onChanged: (value) {
                                chaptersearching(value.trim());
                              },
                              hinttext: "Search",
                              fieldheight: 50,
                              controller: _searchcontroller,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _searchcontroller.clear();
                              },
                              child: Text("Search"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(CupertinoIcons.search),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
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
                itemCount: filteredlist.length,
                itemBuilder: (context, index) {
                  final chapter = filteredlist[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HadithdetailsUrdu(
                              ChapterId: chapter.id.toString(),
                            ),
                          ),
                        );
                      },
                      title: Text(
                        chapter.chapterUrdu ?? '',
                        style: TextStyle(
                          fontFamily: AppFonts.urdufont,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Text(
                        chapter.chapterNumber ?? "No name",
                        style: TextStyle(
                          fontFamily: AppFonts.arabicfont,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      onWillPop: () async {
        if (filteredlist != chaptersList) {
          setState(() {
            filteredlist = chaptersList;
          });
          return false;
        } else {
          AdController().tryShowAd();
          return true;
        }
      },
    );
  }
}
