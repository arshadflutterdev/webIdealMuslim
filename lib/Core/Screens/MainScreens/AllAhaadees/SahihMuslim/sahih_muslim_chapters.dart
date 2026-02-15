import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sahihmuslim/sahimuslimdetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sahihmuslim/sahmuslim_chapters_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class SahihMuslimChaptersss extends StatefulWidget {
  const SahihMuslimChaptersss({super.key});

  @override
  State<SahihMuslimChaptersss> createState() => _SahihMuslimChaptersssState();
}

class _SahihMuslimChaptersssState extends State<SahihMuslimChaptersss> {
  List<Chapters> chaptersList = [];
  bool isLoading = true;
  bool hasError = false;
  Future<void> loadofflinechapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-muslim.json");
      if (file.existsSync()) {
        final fileContent = await file.readAsString();
        final jsonData = jsonDecode(fileContent);
        final chapterData = Sahimuslimchapterlist.fromJson(jsonData);
        setState(() {
          chaptersList = chapterData.chapters ?? [];

          print(chaptersList);

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

  //here is data for website
  Future muslimChapterList() async {
    final muslimapis =
        r"https://hadithapi.com/api/sahih-muslim/chapters?apiKey=$2y$10$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";
    try {
      final response = await http.get(Uri.parse(muslimapis));
      if (response.statusCode == 200) {
        final jsondecode = jsonDecode(response.body);
        print('yOUR APIS ARE GOOD $jsondecode');

        final muslimdata = Sahimuslimchapterlist.fromJson(jsondecode);
        chaptersList = muslimdata.chapters ?? [];
        print("here is chapter list ${chaptersList.length}");
      }
      return chaptersList;
    } catch (e) {
      print(e.toString());
    }
  }

  //hadiths in chapters
  List<String> sahihMuslimHadithRanges = [
    "1-93",
    "94-534",
    "535-679",
    "680-837",
    "838-1161",
    "1162-1570",
    "1571-1837",
    "1838-1951",
    "1952-2044",
    "2045-2070",
    "2071-2089",
    "2090-2123",
    "2124-2263",
    "2264-2495",
    "2496-2780",
    "2781-2791",
    "2792-3398",
    "3399-3568",
    "3569-3652",
    "3653-3743",
    "3744-3770",
    "3771-3801",
    "3802-3962",
    "3963-4140",
    "4141-4163",
    "4164-4204",
    "4205-4235",
    "4236-4254",
    "4255-4342",
    "4343-4398",
    "4399-4470",
    "4471-4498",
    "4499-4519",
    "4520-4700",
    "4701-4971",
    "4972-5063",
    "5064-5126",
    "5127-5384",
    "5385-5585",
    "5586-5645",
    "5646-5861",
    "5862-5884",
    "5885-5896",
    "5897-5937",
    "5938-6168",
    "6169-6499",
    "6500-6722",
    "6723-6774",
    "6775-6804",
    "6805-6951",
    "6952-7021",
    "7022-7127",
    "7128-7232",
    "7233-7414",
    "7415-7520",
    "7521-7561",
  ];

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
        return true;
      },
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
        ),
        backgroundColor: Colors.white,
        body: kIsWeb
            ? FutureBuilder(
                future: muslimChapterList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("No data found"));
                  } else if (snapshot.hasError) {
                    Center(child: Text("We found an Error we working on it"));
                  }
                  return ListView.builder(
                    itemCount: chaptersList.length,
                    itemBuilder: (context, index) {
                      final chapter = chaptersList[index];
                      final hadithlength = sahihMuslimHadithRanges[index];
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
                            hadithlength,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
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
            ? const Center(child: Text("No Internet Connection"))
            : chaptersList.isEmpty
            ? const Center(child: Text("No chapters found"))
            : ListView.builder(
                itemCount: chaptersList.length,
                itemBuilder: (context, index) {
                  final chapter = chaptersList[index];
                  final hadithlength = sahihMuslimHadithRanges[index];
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
                        hadithlength,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
