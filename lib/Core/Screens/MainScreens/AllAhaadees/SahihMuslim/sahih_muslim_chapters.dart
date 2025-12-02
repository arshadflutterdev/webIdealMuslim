import 'dart:convert';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahimuslimdetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahmuslim_chapters_model.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SahihMuslimChaptersss extends StatefulWidget {
  const SahihMuslimChaptersss({super.key});

  @override
  State<SahihMuslimChaptersss> createState() => _SahihMuslimChaptersssState();
}

class _SahihMuslimChaptersssState extends State<SahihMuslimChaptersss> {
  List<Chapters> chaptersList = [];
  List<Chapters> filteredlist = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _searchcontroller = TextEditingController();
  Future searchchapters(String query) async {
    setState(() {
      filteredlist = chaptersList.where((Chapters) {
        final name = Chapters.chapterEnglish?.toString().toLowerCase() ?? "";
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
    final prefs = await SharedPreferences.getInstance();
    const key = 'sahih_muslim_chapters';

    try {
      // 🔹 Step 1: Check if cached data exists
      final cachedData = prefs.getString(key);
      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        final localChapters = Sahimuslimchapterlist.fromJson(decoded);
        setState(() {
          chaptersList = localChapters.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
        });
      }

      // 🔹 Step 2: Always try to fetch fresh data from API
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/sahih-muslim/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔹 Step 3: Save data locally for next time
        await prefs.setString(key, jsonEncode(data));
        final chapterData = Sahimuslimchapterlist.fromJson(data);

        setState(() {
          chaptersList = chapterData.chapters ?? [];
          filteredlist = chaptersList;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load chapters");
      }
    } catch (e) {
      debugPrint("Error loading chapters: $e");
      // 🔹 Step 4: Show error only if there is no local data
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
      onWillPop: () async {
        if (filteredlist != chaptersList) {
          setState(() {
            filteredlist = chaptersList;
          });
        } else {
          AdController().tryShowAd();
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 25,
              color: Colors.black54,
            ),
          ),
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
                                searchchapters(value.trim());
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
        ),
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("No Internet Connection"))
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
                            builder: (context) => Sahimuslimdetails(
                              ChapterIds: chapter.chapterNumber,
                            ),
                          ),
                        );
                      },
                      title: Text(
                        chapter.chapterEnglish ?? "No name",
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: Text(
                        chapter.chapterNumber ?? '',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
