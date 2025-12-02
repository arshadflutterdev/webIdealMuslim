import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/Models/sunan_ibn_e_majah_chapter_model.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/ShowDetails/majah_detailed.dart';

class IbneMajah extends StatefulWidget {
  const IbneMajah({super.key});

  @override
  State<IbneMajah> createState() => _IbneMajahState();
}

class _IbneMajahState extends State<IbneMajah> {
  List<Chapters> chaptersList = [];
  List<Chapters> filteredlist = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _searchcontroller = TextEditingController();
  Future chaptersearching(String query) async {
    setState(() {
      filteredlist = chaptersList.where((Chapters) {
        final name = Chapters.chapterEnglish?.toString().toLowerCase() ?? '';
        final number = Chapters.chapterNumber?.toString().toLowerCase() ?? "";
        final input = query.toLowerCase();
        return name.contains(input) || number.contains(input);
      }).toList();
    });
  }

  final String apiUrl =
      "https://hadithapi.com/api/ibn-e-majah/chapters?apiKey=\$2y\$10\$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future<void> loadChapters() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'ibne_majah_chapters';

    // Load cached data
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        final cachedModel = MajahChapterModel.fromJson(decoded);
        if (!mounted) return;
        setState(() {
          chaptersList = cachedModel.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Cache parse error: $e");
      }
    }

    // Fetch fresh data
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await prefs.setString(cacheKey, jsonEncode(data));

        final model = MajahChapterModel.fromJson(data);
        if (!mounted) return;
        setState(() {
          chaptersList = model.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network error: $e");
      if (!mounted) return;
      setState(() {
        if (chaptersList.isEmpty) hasError = true;
        isLoading = false;
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
