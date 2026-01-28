import 'dart:convert';
import 'dart:io';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SunanAnNasai/ShowDetails/sunananasai_hadith_details.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/Models/sunananasai_chapter_model.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SunanChaptersssUrdu extends StatefulWidget {
  const SunanChaptersssUrdu({super.key});

  @override
  State<SunanChaptersssUrdu> createState() => _SunanChaptersssUrduState();
}

class _SunanChaptersssUrduState extends State<SunanChaptersssUrdu> {
  List<Chapters> chapterList = [];
  bool isLoading = true;
  bool hasError = false;
  Future<void> getDownloadedChapterss() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sunan-nasai.json");
      if (file.existsSync()) {
        final fileContant = await file.readAsString();
        final fileChapters = jsonDecode(fileContant);
        final chaptersss = SunanAnNasaiChapterModel.fromJson(fileChapters);
        setState(() {
          chapterList = chaptersss.chapters ?? [];
          isLoading = false;
        });
      } else {
        print("there is no file exists");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("error related ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    getDownloadedChapterss();
  }

  List<String> nasaiHadithRanges = [
    "1-100",
    "101-200",
    "201-300",
    "301-400",
    "401-500",
    "501-600",
    "601-700",
    "701-800",
    "801-900",
    "901-1000",
    "1001-1100",
    "1101-1200",
    "1201-1300",
    "1301-1400",
    "1401-1500",
    "1501-1600",
    "1601-1700",
    "1701-1800",
    "1801-1900",
    "1901-2000",
    "2001-2100",
    "2101-2200",
    "2201-2300",
    "2301-2400",
    "2401-2500",
    "2501-2600",
    "2601-2700",
    "2701-2800",
    "2801-2900",
    "2901-3000",
    "3001-3100",
    "3101-3200",
    "3201-3300",
    "3301-3400",
    "3401-3500",
    "3501-3600",
    "3601-3700",
    "3701-3800",
    "3801-3900",
    "3901-4000",
    "4001-4100",
    "4101-4200",
    "4201-4300",
    "4301-4400",
    "4401-4500",
    "4501-4600",
    "4601-4700",
    "4701-4800",
    "4801-4900",
    "4901-5000",
    "5001-5100",
    "5101-5200",
    "5201-5279",
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("No Internet Connection ❌"))
            : chapterList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chapterList.length,
                itemBuilder: (context, index) {
                  final chapter = chapterList[index];
                  final hadithlength = nasaiHadithRanges[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SunananasaiHadithDetailsUrdu(
                              chapterno: chapter.chapterNumber,
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
                    //         builder: (context) => SunananasaiHadithDetailsUrdu(
                    //           chapterno: chapter.chapterNumber,
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
