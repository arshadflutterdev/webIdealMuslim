import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/utils.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahmuslim_chapters_model.dart';

class Bukhari extends StatefulWidget {
  final String title;
  const Bukhari({super.key, required this.title});

  @override
  State<Bukhari> createState() => _BukhariState();
}

class _BukhariState extends State<Bukhari> {
  List<Chapters> chaptersList = [];
  List<Chapters> filturedlist = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  /// Load from SharedPreferences first, then API if not cached
  Future<void> loadChapters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('bukhari_chapters');

      if (cachedData != null) {
        // ✅ Load cached chapters
        final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
        final localChapters = Sahimuslimchapterlist.fromJson(jsonMap);
        setState(() {
          chaptersList = localChapters.chapters ?? [];
          filturedlist = chaptersList;
          isLoading = false;
        });
      } else {
        // ✅ First time → fetch from API and save
        await fetchAndCacheChapters();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Fetch from API and store in SharedPreferences
  Future<void> fetchAndCacheChapters() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/sahih-bukhari/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final chaptersData = Sahimuslimchapterlist.fromJson(jsonData);

        // ✅ Save full JSON in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bukhari_chapters', jsonEncode(jsonData));

        setState(() {
          chaptersList = chaptersData.chapters ?? [];
          filturedlist = chaptersList;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  TextEditingController search = TextEditingController();
  Future searchapter(String query) async {
    setState(() {
      filturedlist = chaptersList.where((Chapters) {
        final name = Chapters.chapterEnglish?.toString().toLowerCase() ?? "";
        final number = Chapters.chapterNumber?.toString().toLowerCase() ?? "";
        final input = query.toLowerCase();
        return name.contains(input) || number.contains(input);
      }).toList();
    });
  }

  //here is hadith count
  List<String> hadithRanges = [
    "1-7",
    "8-58",
    "59-134",
    "135-247",
    "248-293",
    "294-333",
    "334-348",
    "349-520",
    "521-602",
    "603-875",
    "876-941",
    "942-947",
    "948-989",
    "990-1004",
    "1005-1039",
    "1040-1065",
    "1067-1079",
    "1080-1119",
    "1120-1187",
    "1188-1197",
    "1198-1223",
    "1224-1236",
    "1237-1394",
    "1395-1512",
    "1513-1771",
    "1773-1805",
    "1806-1820",
    "1821-1866",
    "1867-1890",
    "1891-2007",
    "2008-2013",
    "2014-2024",
    "2025-2046",
    "2047-2238",
    "2239-2256",
    "2257-2259",
    "2260-2285",
    "2287-2289",
    "2290-2298",
    "2299-2319",
    "2320-2350",
    "2351-2383",
    "2385-2409",
    "2410-2425",
    "2426-2439",
    "2440-2482",
    "2483-2507",
    "2508-2515",
    "2517-2559",
    "2560-2565",
    "2566-2636",
    "2637-2689",
    "2690-2710",
    "2711-2737",
    "2738-2781",
    "2782-3090",
    "3091-3155",
    "3156-3189",
    "3190-3325",
    "3326-3488",
    "3489-3648",
    "3649-3775",
    "3776-3948",
    "3949-4473",
    "4474-4977",
    "4978-5062",
    "5063-5250",
    "5251-5350",
    "5351-5372",
    "5373-5466",
    "5467-5474",
    "5475-5544",
    "5545-5574",
    "5575-5639",
    "5640-5677",
    "5678-5782",
    "5783-5969",
    "5970-6226",
    "6227-6303",
    "6304-6411",
    "6412-6593",
    "6594-6620",
    "6621-6707",
    "6708-6722",
    "6723-6771",
    "6772-6859",
    "6861-6917",
    "6918-6939",
    "6940-6952",
    "6953-6981",
    "6982-7047",
    "7048-7136",
    "7137-7225",
    "7226-7245",
    "7246-7267",
    "7268-7370",
    "7371-7563",
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (filturedlist != chaptersList) {
          setState(() {
            filturedlist = chaptersList;
          });
          return false;
        } else {
          AdController().tryShowAd();
          return true;
        }
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                                searchapter(value.trim());
                              },
                              hinttext: "Search",
                              fieldheight: 50,
                              controller: search,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                search.clear();
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

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 25,
              color: Colors.black54,
            ),
          ),
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.white,
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
                itemCount: filturedlist.length,
                itemBuilder: (context, index) {
                  final chapter = filturedlist[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Hadithdetails(ChapterId: chapter.id.toString()),
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
              ),
      ),
    );
  }
}
