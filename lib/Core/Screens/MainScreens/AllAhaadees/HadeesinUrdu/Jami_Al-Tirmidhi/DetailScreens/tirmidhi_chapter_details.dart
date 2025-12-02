import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/Models/chapter_model.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TirmidhiChapterDetailsUrdu extends StatefulWidget {
  const TirmidhiChapterDetailsUrdu({super.key});

  @override
  State<TirmidhiChapterDetailsUrdu> createState() =>
      _TirmidhiChapterDetailsUrduState();
}

class _TirmidhiChapterDetailsUrduState
    extends State<TirmidhiChapterDetailsUrdu> {
  List<Chapters> chaptersList = [];
  List<Chapters> filteredlist = [];
  bool isLoading = true;
  bool hasError = false;

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
    loadChapters();
  }

  Future<void> loadChapters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'tirmidhi_chapters';

      // 🔹 Step 1: Load Cached Data if available
      final cachedData = prefs.getString(key);
      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        final localModel = TirmidhiModel.fromJson(decoded);
        setState(() {
          chaptersList = localModel.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
        });
      }

      // 🔹 Step 2: Fetch Fresh Data from API
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/al-tirmidhi/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(
          key,
          jsonEncode(data),
        ); // ✅ Cache it for next time
        final model = TirmidhiModel.fromJson(data);
        setState(() {
          chaptersList = model.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to fetch data from API");
      }
    } catch (e) {
      debugPrint("⚠️ Error loading chapters: $e");
      if (chaptersList.isEmpty) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
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
                            builder: (context) => TirmidhiDetailsUrdu(
                              chapterId: chapter.chapterNumber ?? '',
                            ),
                          ),
                        );
                      },
                      title: Text(
                        chapter.chapterUrdu ?? "No name",
                        style: TextStyle(
                          fontFamily: AppFonts.urdufont,
                          fontSize: 20,
                          height: 2.2,
                        ),
                      ),
                      trailing: Text(
                        chapter.chapterNumber ?? '',
                        style: TextStyle(
                          fontFamily: AppFonts.arabicfont,
                          fontSize: 25,
                          color: Colors.black,
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
