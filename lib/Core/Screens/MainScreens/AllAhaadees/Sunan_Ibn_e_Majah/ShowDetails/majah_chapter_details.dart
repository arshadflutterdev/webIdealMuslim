import 'dart:convert';
import 'dart:io';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/Models/sunan_ibn_e_majah_chapter_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/ShowDetails/majah_detailed.dart';

class IbneMajah extends StatefulWidget {
  const IbneMajah({super.key});

  @override
  State<IbneMajah> createState() => _IbneMajahState();
}

class _IbneMajahState extends State<IbneMajah> {
  List<Chapters> chaptersList = [];

  bool isLoading = true;
  bool hasError = false;

  //function to fetch chaptersOffline
  Future<void> getDownloadChapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/ibn-e-majah.json");
      print("here is file path ${file.path}");

      final fileContant = await file.readAsString();

      final filedecode = jsonDecode(fileContant);
      final chaptersss = MajahChapterModel.fromJson(filedecode);
      setState(() {
        chaptersList = chaptersss.chapters ?? [];
        print("all chapters instance $chaptersList");
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("error regarding chapters ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    getDownloadChapters();
  }

  List<String> ibnMajahHadithRanges = [
    "1-55",
    "56-110",
    "111-165",
    "166-220",
    "221-275",
    "276-330",
    "331-385",
    "386-440",
    "441-495",
    "496-550",
    "551-605",
    "606-660",
    "661-715",
    "716-770",
    "771-825",
    "826-880",
    "881-935",
    "936-990",
    "991-1045",
    "1046-1100",
    "1101-1155",
    "1156-1210",
    "1211-1265",
    "1266-1320",
    "1321-1375",
    "1376-1430",
    "1431-1485",
    "1486-1540",
    "1541-1595",
    "1596-1650",
    "1651-1705",
    "1706-1760",
    "1761-1815",
    "1816-1870",
    "1871-1925",
    "1926-1980",
    "1981-2035",
    "2036-2090",
    "2091-2145",
    "2146-2200",
    "2201-2255",
    "2256-2310",
    "2311-2365",
    "2366-2420",
    "2421-2475",
    "2476-2530",
    "2531-2585",
    "2586-2640",
    "2641-2694",
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

        backgroundColor: isLoading ? Colors.white : Colors.white,
        body: Builder(
          builder: (context) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            } else if (hasError) {
              return const Center(child: Text("No Internet Connection ❌"));
            } else if (chaptersList.isEmpty) {
              return const Center(child: Text("No chapters found"));
            }

            return ListView.builder(
              itemCount: chaptersList.length,
              itemBuilder: (context, index) {
                final hadithlength = ibnMajahHadithRanges[index];

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
                              MajahDetailed(chapterIdss: chapter.chapterNumber),
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
