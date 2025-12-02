import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SunanAnNasai/ShowDetails/sunananasai_hadith_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/Models/sunananasai_chapter_model.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/ShowDetails/sunananasai_hadith_details.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SunanChaptersssUrdu extends StatefulWidget {
  const SunanChaptersssUrdu({super.key});

  @override
  State<SunanChaptersssUrdu> createState() => _SunanChaptersssUrduState();
}

class _SunanChaptersssUrduState extends State<SunanChaptersssUrdu> {
  List<Chapters> chapterList = [];
  List<Chapters> filteredlist = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _searchcontroller = TextEditingController();
  Future chaptersearching(String query) async {
    setState(() {
      filteredlist = chapterList.where((Chapters) {
        final name = Chapters.chapterUrdu?.toString().toLowerCase() ?? '';
        final number = Chapters.chapterNumber?.toString().toLowerCase() ?? "";
        final input = query.toLowerCase();
        return name.contains(input) || number.contains(input);
      }).toList();
    });
  }

  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future<void> loadChapters() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'sunananasai_chapters';

    // 🔹 1) Load cache FIRST
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      try {
        final jsonData = jsonDecode(cachedData);
        final model = SunanAnNasaiChapterModel.fromJson(jsonData);

        setState(() {
          chapterList = model.chapters ?? [];
          filteredlist = chapterList;
          isLoading = false;
          hasError = false;
        });

        print("📌 Loaded from CACHE (Offline Mode)");
        return; // 🔥 DO NOT FETCH API AGAIN
      } catch (e) {
        print("Cache error: $e");
      }
    }

    // 🔹 2) No cache found → Fetch from API
    try {
      final url =
          "https://hadithapi.com/api/sunan-nasai/chapters?apiKey=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save for future offline use
        await prefs.setString(cacheKey, jsonEncode(data));

        final model = SunanAnNasaiChapterModel.fromJson(data);

        setState(() {
          chapterList = model.chapters ?? [];
          filteredlist = chapterList;
          isLoading = false;
          hasError = false;
        });

        print("🌍 Loaded from API + Cached");
      } else {
        throw Exception("API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
                            builder: (context) => SunananasaiHadithDetailsUrdu(
                              chapterno: chapter.chapterNumber,
                            ),
                          ),
                        );
                      },
                      title: Text(
                        chapter.chapterUrdu ?? "No name",
                        style: TextStyle(
                          fontFamily: AppFonts.urdufont,
                          fontSize: 20,
                          height: 2,
                        ),
                      ),
                      trailing: Text(
                        chapter.chapterNumber ?? '',
                        style: TextStyle(
                          fontFamily: AppFonts.arabicfont,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      onWillPop: () async {
        if (filteredlist != chapterList) {
          setState(() {
            filteredlist = chapterList;
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
