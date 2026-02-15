import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sahihmuslim/sahmuslim_chapters_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Bukhari extends StatefulWidget {
  final String title;
  const Bukhari({super.key, required this.title});

  @override
  State<Bukhari> createState() => _BukhariState();
}

class _BukhariState extends State<Bukhari> {
  List<Chapters> chaptersList = [];

  bool isLoading = true;
  bool hasError = false;
  //here is function to load offline chapterss
  Future<void> loadofflinechapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-bukhari.json");
      if (file.existsSync()) {
        final fileContent = await file.readAsString();
        final jsonData = jsonDecode(fileContent);
        final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
        setState(() {
          chaptersList = chapterData.chapters ?? [];

          print(chaptersList);
          // filturedlist = chaptersList;
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

  //list hadiths in evey chapters
  List<String> hadeesInChapter = [
    "1-7",
    "8-58",
    "59-134",
    "135-247",
    "248-293",
    "294-333",
    "334-348",
    "349-520",
    "521-602",
    "603-734",
    "735-875",
    "876-941",
    "942-947",
    "948-989",
    "990-1004",
    "1005-1039",
    "1040-1066",
    "1067-1079",
    "1080-1119",
    "1120-1187",
    "1188-1197",
    "1198-1223",
    "1224-1236",
    "1237-1394",
    "1395-1512",
    "1513-1772",
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
    "2260-2286",
    "2287-2289",
    "2290-2298",
    "2299-2319",
    "2320-2350",
    "2351-2384",
    "2385-2409",
    "2410-2425",
    "2426-2439",
    "2440-2482",
    "2483-2507",
    "2508-2516",
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
    "6772-6801",
    "6802-6860",
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

  Future<List<Chapters>> getBukhariChapters() async {
    final apiKey =
        "\$2y\$10\$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";
    final url =
        "https://hadithapi.com/api/sahih-bukhari/chapters?apiKey=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsondecode = jsonDecode(response.body);
        final bukhariData = Sahimuslimchapterlist.fromJson(jsondecode);
        chaptersList = bukhariData.chapters ?? [];

        print("here is total lentght of cheapters ${chaptersList.length}");

        return chaptersList;
      } else {
        throw Exception("faild to load data");
      }
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    loadofflinechapters();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return WillPopScope(
      onWillPop: () async {
        AdController().tryShowAd();
        Navigator.pop(context);
        return false;
      },

      child: Scaffold(
        backgroundColor: Colors.white,
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

          automaticallyImplyLeading: false,

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
        body: kIsWeb
            ? FutureBuilder<List<Chapters>>(
                future: getBukhariChapters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("Sorry no data found"));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error found in data(we are fixing it)"),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: chaptersList.length,
                      itemBuilder: (context, index) {
                        final hadithlength = hadeesInChapter[index];
                        final chapter = chaptersList[index];
                        return Card(
                          elevation: 3,
                          color: Colors.white,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Hadithdetails(
                                    ChapterId: chapter.id.toString(),
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
                    );
                  }
                },
              )
            : isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("Error loading chapters"))
            : chaptersList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chaptersList.length,
                itemBuilder: (context, index) {
                  final hadithlength = hadeesInChapter[index];
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
                                Hadithdetails(ChapterId: chapter.id.toString()),
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
    );
  }
}
