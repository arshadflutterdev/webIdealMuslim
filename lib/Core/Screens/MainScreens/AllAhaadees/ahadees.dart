import 'dart:convert';
import 'dart:io';

import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_jami-al-tirmidhi.dart';
import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-muslim.dart';
import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_abu_dawood.dart';
import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_annasai.dart';
import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_ibn_majah.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/sahibukhari.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahih_muslim_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/sahibukhari.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahihMuslim/sahih_muslim_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';
import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-bukhari.dart';

import 'package:Muslim/Data/Models/ahadeesmodel.dart';

class Ahadees extends StatefulWidget {
  const Ahadees({super.key});

  @override
  State<Ahadees> createState() => _AhadeesState();
}

class _AhadeesState extends State<Ahadees> with TickerProviderStateMixin {
  late TabController _controller;
  List<Books> booksList = [];
  bool isLoading = true;
  bool hasError = false;

  Map<String, bool> isDownloadingMap = {};
  Map<String, bool> isDownloadedMap = {};

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    loadBooks();
  }

  Future<void> checkAllDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    for (var book in booksList.take(6)) {
      final file = File("${dir.path}/${book.bookSlug}.json");
      setState(() {
        isDownloadedMap[book.bookSlug ?? ""] = file.existsSync();
        isDownloadingMap[book.bookSlug ?? ""] = false;
      });
    }
  }

  Future<void> loadBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('hadith_books');

      if (cachedData != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
        final localBooks = Hadithnamesss.fromJson(jsonMap);
        setState(() {
          booksList = localBooks.books?.take(6).toList() ?? [];
          isLoading = false;
        });
        checkAllDownloads();
      } else {
        await fetchAndCacheBooks();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndCacheBooks() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/books?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final booksData = Hadithnamesss.fromJson(jsonData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('hadith_books', jsonEncode(jsonData));

        setState(() {
          booksList = booksData.books?.take(6).toList() ?? [];
          isLoading = false;
        });

        checkAllDownloads();
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  List<Color> namecolors = [
    Color(0xFF0046FF),
    Color(0xFF59AC77),
    Color(0xFFFFC50F),
    Color(0xFFFF6C0C),
    Color(0xFF540863),
    Color(0xFFB87C4C),
  ];

  Map<String, String> urduBookNames = {
    "sahih-bukhari": "صحیح بخاری",
    "sahih-muslim": "صحیح مسلم",
    "al-tirmidhi": "جامع الترمذی",
    "abu-dawood": "سنن ابوداؤد",
    "ibn-e-majah": "ابن ماجہ",
    "sunan-nasai": "سنن نسائی",
  };

  Future<void> downloadBook(String slug) async {
    setState(() {
      isDownloadingMap[slug] = true;
    });

    try {
      if (slug == "sahih-bukhari") {
        await DownloadSahiBukhar().downloadbook();
      } else if (slug == "sahih-muslim") {
        await DownloadSahimuslim().downloadsahimuslim();
      } else if (slug == "al-tirmidhi") {
        await DownloadJamialtirmidhi().downloadjamiatirmidhi();
      } else if (slug == "abu-dawood") {
        await DownloadSunanAbuDawood().getdownload();
      } else if (slug == "ibn-e-majah") {
        await DownloadSunanIbnMajah().getdownloadbook();
      } else if (slug == "sunan-nasai") {
        await DownloadSunanAnnasai().getDownload();
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$slug.json");

      setState(() {
        isDownloadedMap[slug] = file.existsSync();
        isDownloadingMap[slug] = false;
      });

      if (isDownloadedMap[slug] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(("$slug downloaded successfully!"))),
        );
      }
    } catch (e) {
      setState(() {
        isDownloadingMap[slug] = false;
      });
      print("Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xFF305CDE),
          title: Text(
            "Hadees",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              letterSpacing: 3,
              fontFamily: AppFonts.engfont,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: TabBar(
                  controller: _controller,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(color: Colors.green),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsetsGeometry.zero,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: "English"),
                    Tab(text: "Urdu"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  // English Tab
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : hasError
                      ? const Center(child: Text("No Internet Connection"))
                      : booksList.isEmpty
                      ? const Center(child: Text("No Hadith books found"))
                      : ListView.builder(
                          itemCount: booksList.length,
                          itemBuilder: (context, index) {
                            final book = booksList[index];
                            final slug = book.bookSlug ?? "";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: SizedBox(
                                height: height * 0.09,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      // Navigate chapters (keep original logic)
                                      if (slug == "sahih-bukhari") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Bukhari(title: ''),
                                          ),
                                        );
                                      } else if (slug == "sahih-muslim") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SahihMuslimChaptersss(),
                                          ),
                                        );
                                      } else if (slug == "al-tirmidhi") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TirmidhiChapterDetails(),
                                          ),
                                        );
                                      } else if (slug == "abu-dawood") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SunanChapterDetails(),
                                          ),
                                        );
                                      } else if (slug == "ibn-e-majah") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => IbneMajah(),
                                          ),
                                        );
                                      } else if (slug == "sunan-nasai") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SunanChaptersss(),
                                          ),
                                        );
                                      }
                                    },
                                    trailing: SizedBox(
                                      width: width * 0.20,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed:
                                                isDownloadingMap[slug] ==
                                                        true ||
                                                    isDownloadedMap[slug] ==
                                                        true
                                                ? null
                                                : () {
                                                    downloadBook(slug);
                                                  },
                                            icon: isDownloadingMap[slug] == true
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.green,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : isDownloadedMap[slug] == true
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : Icon(
                                                    Icons.download,
                                                    color: Colors.black54,
                                                  ),
                                          ),

                                          Text(
                                            book.chaptersCount ?? "",
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    title: Text(
                                      book.bookName ?? "",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: namecolors[index],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  // Urdu Tab (keep same design, change titles to Urdu)
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : hasError
                      ? const Center(child: Text("No Internet Connection"))
                      : booksList.isEmpty
                      ? const Center(child: Text("No Hadith books found"))
                      : ListView.builder(
                          itemCount: booksList.length,
                          itemBuilder: (context, index) {
                            final book = booksList[index];
                            final slug = book.bookSlug ?? "";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: SizedBox(
                                height: height * 0.09,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      if (slug == "sahih-bukhari") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BukhariUrdu(title: ''),
                                          ),
                                        );
                                      } else if (slug == "sahih-muslim") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SahihMuslimChaptersssUrdu(),
                                          ),
                                        );
                                      } else if (slug == "al-tirmidhi") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TirmidhiChapterDetailsUrdu(),
                                          ),
                                        );
                                      } else if (slug == "abu-dawood") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SunanChapterDetailsUrdu(),
                                          ),
                                        );
                                      } else if (slug == "ibn-e-majah") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                IbneMajahUrdu(),
                                          ),
                                        );
                                      } else if (slug == "sunan-nasai") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SunanChaptersssUrdu(),
                                          ),
                                        );
                                      }
                                    },
                                    trailing: Text(
                                      urduBookNames[slug] ??
                                          book.bookName ??
                                          "",
                                      style: TextStyle(
                                        fontFamily: AppFonts.urdufont,
                                        fontSize: 22,
                                        color: namecolors[index],
                                      ),
                                    ),
                                    title: SizedBox(
                                      width: width * 0.50,
                                      child: Row(
                                        children: [
                                          Text(
                                            book.chaptersCount ?? "",
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Gap(10),
                                          IconButton(
                                            onPressed:
                                                isDownloadingMap[slug] ==
                                                        true ||
                                                    isDownloadedMap[slug] ==
                                                        true
                                                ? null
                                                : () {
                                                    downloadBook(slug);
                                                  },
                                            icon: isDownloadingMap[slug] == true
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.green,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : isDownloadedMap[slug] == true
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : Icon(
                                                    Icons.download,
                                                    color: Colors.black54,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
