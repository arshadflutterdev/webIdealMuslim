import 'dart:convert';
import 'dart:io';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Models/chapters_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Show_details/sunan_hadith_details.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SunanChapterDetails extends StatefulWidget {
  const SunanChapterDetails({super.key});

  @override
  State<SunanChapterDetails> createState() => _SunanChapterDetailsState();
}

class _SunanChapterDetailsState extends State<SunanChapterDetails> {
  List<Chapters> chapterList = [];

  bool isLoading = false;
  bool hasError = false;
  //function to loadOffline chapterss
  Future<void> getdownloadedChapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/abu-dawood.json");
      final fileContant = await file.readAsString();
      final chaptersss = jsonDecode(fileContant);
      final chapterssList = SunanChapters.fromJson(chaptersss);
      setState(() {
        chapterList = chapterssList.chapters ?? [];
        print("here is All chapters $chapterList");
        isLoading = false;
        // hasError = true;
      });
    } catch (e) {
      throw Exception("Failed to fetch data ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();

    getdownloadedChapters();
  }

  List<String> abuDawoodHadithRanges = [
    "1-122",
    "123-245",
    "246-368",
    "369-491",
    "492-614",
    "615-737",
    "738-860",
    "861-983",
    "984-1106",
    "1107-1229",
    "1230-1352",
    "1353-1475",
    "1476-1598",
    "1599-1721",
    "1722-1844",
    "1845-1967",
    "1968-2090",
    "2091-2213",
    "2214-2336",
    "2337-2459",
    "2460-2582",
    "2583-2705",
    "2706-2828",
    "2829-2951",
    "2952-3074",
    "3075-3197",
    "3198-3320",
    "3321-3443",
    "3444-3566",
    "3567-3689",
    "3690-3812",
    "3813-3935",
    "3936-4058",
    "4059-4181",
    "4182-4304",
    "4305-4427",
    "4428-4550",
    "4551-4673",
    "4674-4796",
    "4797-4919",
    "4920-5042",
    "5043-5174",
    "5175-5274",
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
            ? const Center(child: Text("Failed to fetch"))
            : chapterList.isEmpty
            ? const Center(child: Text("No chapters available"))
            : ListView.builder(
                itemCount: chapterList.length,
                itemBuilder: (context, index) {
                  final chapter = chapterList[index];
                  final hadithlength = abuDawoodHadithRanges[index];

                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SunanHadithDetails(
                              chapterno: chapter.chapterNumber ?? '',
                            ),
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
      onWillPop: () async {
        AdController().tryShowAd();
        return true;
      },
    );
  }
}
