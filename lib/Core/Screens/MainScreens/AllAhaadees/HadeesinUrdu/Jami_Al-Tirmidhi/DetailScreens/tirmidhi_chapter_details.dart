import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_details.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/Models/chapter_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class TirmidhiChapterDetailsUrdu extends StatefulWidget {
  const TirmidhiChapterDetailsUrdu({super.key});

  @override
  State<TirmidhiChapterDetailsUrdu> createState() =>
      _TirmidhiChapterDetailsUrduState();
}

class _TirmidhiChapterDetailsUrduState
    extends State<TirmidhiChapterDetailsUrdu> {
  List<Chapters> chaptersList = [];

  bool isLoading = true;
  bool hasError = false;
  Future<void> getdownloadedchapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/al-tirmidhi.json");
      if (file.existsSync()) {
        final fileContant = await file.readAsString();
        final chapterDataa = jsonDecode(fileContant);
        final chapterrrr = TirmidhiModel.fromJson(chapterDataa);

        setState(() {
          chaptersList = chapterrrr.chapters ?? [];
          print("here is all chapters=$chaptersList");

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future getTirmidhichapters() async {
    final tirmidhiApis =
        r"https://hadithapi.com/api/al-tirmidhi/chapters?apiKey=$2y$10$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";
    try {
      final response = await http.get(Uri.parse(tirmidhiApis));
      if (response.statusCode == 200) {
        print("Your apis are working correctly");
        final jsondecode = jsonDecode(response.body);
        final tirmidhiData = TirmidhiModel.fromJson(jsondecode);
        chaptersList = tirmidhiData.chapters ?? [];
      }
      return chaptersList;
    } catch (e) {
      e.toString();
    }
  }

  //hadiths in chapters
  List<String> tirmidhiHadithRanges = [
    "1-79",
    "80-158",
    "159-237",
    "238-316",
    "317-395",
    "396-474",
    "475-553",
    "554-632",
    "633-711",
    "712-790",
    "791-869",
    "870-948",
    "949-1027",
    "1028-1106",
    "1107-1185",
    "1186-1264",
    "1265-1343",
    "1344-1422",
    "1423-1501",
    "1502-1580",
    "1581-1659",
    "1660-1738",
    "1739-1817",
    "1818-1896",
    "1897-1975",
    "1976-2054",
    "2055-2133",
    "2134-2212",
    "2213-2291",
    "2292-2370",
    "2371-2449",
    "2450-2528",
    "2529-2607",
    "2608-2686",
    "2687-2765",
    "2766-2844",
    "2845-2923",
    "2924-3002",
    "3003-3081",
    "3082-3160",
    "3161-3239",
    "3240-3318",
    "3319-3397",
    "3398-3476",
    "3477-3555",
    "3556-3634",
    "3635-3713",
    "3714-3792",
    "3793-3871",
    "3872-3956",
  ];

  @override
  void initState() {
    super.initState();
    getdownloadedchapters();
    getTirmidhichapters();
  }

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
                future: getTirmidhichapters(),
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
                      final hadithlength = tirmidhiHadithRanges[index];

                      return Card(
                        elevation: 3,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TirmidhiDetailsUrdu(
                                  chapterId: chapter.chapterNumber ?? '',
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
                                    hadithlength,
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
                        //         builder: (context) => TirmidhiDetailsUrdu(
                        //           chapterId: chapter.chapterNumber ?? '',
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   title: Text(
                        //     chapter.chapterUrdu ?? "No name",
                        //     style: TextStyle(
                        //       fontFamily: AppFonts.urdufont,
                        //       fontSize: 20,
                        //       height: 2.2,
                        //     ),
                        //   ),
                        //   trailing: Text(
                        //     hadithlength,
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
            ? const Center(child: Text("No Internet Connection ❌"))
            : chaptersList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chaptersList.length,
                itemBuilder: (context, index) {
                  final chapter = chaptersList[index];
                  final hadithlength = tirmidhiHadithRanges[index];

                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TirmidhiDetailsUrdu(
                              chapterId: chapter.chapterNumber ?? '',
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
                                hadithlength,
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
                    //         builder: (context) => TirmidhiDetailsUrdu(
                    //           chapterId: chapter.chapterNumber ?? '',
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   title: Text(
                    //     chapter.chapterUrdu ?? "No name",
                    //     style: TextStyle(
                    //       fontFamily: AppFonts.urdufont,
                    //       fontSize: 20,
                    //       height: 2.2,
                    //     ),
                    //   ),
                    //   trailing: Text(
                    //     hadithlength,
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
