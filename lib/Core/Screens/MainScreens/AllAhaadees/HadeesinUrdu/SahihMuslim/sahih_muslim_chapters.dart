import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sahihmuslim/sahimuslimdetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sahihmuslim/sahimuslimdetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sahihmuslim/sahmuslim_chapters_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SahihMuslimChaptersssUrdu extends StatefulWidget {
  const SahihMuslimChaptersssUrdu({super.key});

  @override
  State<SahihMuslimChaptersssUrdu> createState() =>
      _SahihMuslimChaptersssUrduState();
}

class _SahihMuslimChaptersssUrduState extends State<SahihMuslimChaptersssUrdu> {
  List<Chapters> chaptersList = [];

  bool isLoading = true;
  bool hasError = false;
  Future<void> loadofflinechapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-muslim.json");
      if (file.existsSync()) {
        final fileContent = await file.readAsString();
        final jsonData = jsonDecode(fileContent);
        final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
        setState(() {
          chaptersList = chapterData.chapters ?? [];

          print(chaptersList);
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

  //let's get data for web
  Future muslimChapterList() async {
    final muslimapis =
        r"https://hadithapi.com/api/sahih-muslim/chapters?apiKey=$2y$10$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";
    try {
      final response = await http.get(Uri.parse(muslimapis));
      if (response.statusCode == 200) {
        final jsondecode = jsonDecode(response.body);
        print('yOUR APIS ARE GOOD $jsondecode');

        final muslimdata = Sahimuslimchapterlist.fromJson(jsondecode);
        chaptersList = muslimdata.chapters ?? [];
        print("here is chapter list ${chaptersList.length}");
      }
      return chaptersList;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    loadofflinechapters();
    muslimChapterList();
  }

  //hadiths in chapters
  List<String> sahihMuslimHadithRanges = [
    "1-93",
    "94-534",
    "535-679",
    "680-837",
    "838-1161",
    "1162-1570",
    "1571-1837",
    "1838-1951",
    "1952-2044",
    "2045-2070",
    "2071-2089",
    "2090-2123",
    "2124-2263",
    "2264-2495",
    "2496-2780",
    "2781-2791",
    "2792-3398",
    "3399-3568",
    "3569-3652",
    "3653-3743",
    "3744-3770",
    "3771-3801",
    "3802-3962",
    "3963-4140",
    "4141-4163",
    "4164-4204",
    "4205-4235",
    "4236-4254",
    "4255-4342",
    "4343-4398",
    "4399-4470",
    "4471-4498",
    "4499-4519",
    "4520-4700",
    "4701-4971",
    "4972-5063",
    "5064-5126",
    "5127-5384",
    "5385-5585",
    "5586-5645",
    "5646-5861",
    "5862-5884",
    "5885-5896",
    "5897-5937",
    "5938-6168",
    "6169-6499",
    "6500-6722",
    "6723-6774",
    "6775-6804",
    "6805-6951",
    "6952-7021",
    "7022-7127",
    "7128-7232",
    "7233-7414",
    "7415-7520",
    "7521-7561",
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                kIsWeb
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchAhadeesWeb(),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchAhadees(),
                        ),
                      );
              },
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search_rounded, size: isMobile ? 25 : 40),
              ),
            ),
          ],

          backgroundColor: Colors.white,

          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
        backgroundColor: Colors.white,
        body: kIsWeb
            ? FutureBuilder(
                future: muslimChapterList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }
                  return ListView.builder(
                    itemCount: chaptersList.length,
                    itemBuilder: (context, index) {
                      final chapter = chaptersList[index];
                      final hadithss = sahihMuslimHadithRanges[index];
                      return Card(
                        elevation: 3,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SahimuslimdetailsUrdu(
                                  ChapterIds: chapter.chapterNumber,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            // height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  Text(
                                    hadithss,
                                    style: TextStyle(
                                      fontFamily: AppFonts.arabicfont,
                                      fontSize: 16,
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      maxLines: 3, // 🔴 important
                                      overflow:
                                          TextOverflow.ellipsis, // 🔴 important
                                      textAlign:
                                          TextAlign.right, // Urdu ke liye
                                      chapter.chapterUrdu ?? '',
                                      style: TextStyle(
                                        fontFamily: AppFonts.urdufont,
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ListTile(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => SahimuslimdetailsUrdu(
                        //           ChapterIds: chapter.chapterNumber,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   title: Text(
                        //     chapter.chapterUrdu ?? "No name",
                        //     style: TextStyle(
                        //       fontFamily: AppFonts.urdufont,
                        //       fontSize: 20,
                        //       height: 2,
                        //     ),
                        //   ),
                        //   trailing: Text(
                        //     hadithss,
                        //     style: TextStyle(
                        //       fontFamily: AppFonts.arabicfont,
                        //       fontSize: 16,
                        //       color: Colors.black87,
                        //     ),
                        //   ),
                        // ),
                      );
                    },
                  );
                },
              )
            : isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("No Internet Connection"))
            : chaptersList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chaptersList.length,
                itemBuilder: (context, index) {
                  final chapter = chaptersList[index];
                  final hadithss = sahihMuslimHadithRanges[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SahimuslimdetailsUrdu(
                              ChapterIds: chapter.chapterNumber,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        // height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Text(
                                hadithss,
                                style: TextStyle(
                                  fontFamily: AppFonts.arabicfont,
                                  fontSize: 16,
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  maxLines: 3, // 🔴 important
                                  overflow:
                                      TextOverflow.ellipsis, // 🔴 important
                                  textAlign: TextAlign.right, // Urdu ke liye
                                  chapter.chapterUrdu ?? '',
                                  style: TextStyle(
                                    fontFamily: AppFonts.urdufont,
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ListTile(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => SahimuslimdetailsUrdu(
                    //           ChapterIds: chapter.chapterNumber,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   title: Text(
                    //     chapter.chapterUrdu ?? "No name",
                    //     style: TextStyle(
                    //       fontFamily: AppFonts.urdufont,
                    //       fontSize: 20,
                    //       height: 2,
                    //     ),
                    //   ),
                    //   trailing: Text(
                    //     hadithss,
                    //     style: TextStyle(
                    //       fontFamily: AppFonts.arabicfont,
                    //       fontSize: 16,
                    //       color: Colors.black87,
                    //     ),
                    //   ),
                    // ),
                  );
                },
              ),
      ),
      onWillPop: () async {
        AdController().tryShowAd();
        return true;
      },
    );
  }
}
