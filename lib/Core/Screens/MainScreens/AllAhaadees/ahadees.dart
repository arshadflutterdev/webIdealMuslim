import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/sahibukhari.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahihMuslim/sahih_muslim_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/downloadbook.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Muslim/Data/Models/ahadeesmodel.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/sahibukhari.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahih_muslim_chapters.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  Future<void> checkIfDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/sahi-bukhari.json");
    setState(() {
      isDownloaded = file.existsSync();
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    loadBooks();
    checkIfDownloaded();
  }

  /// First try to load from SharedPreferences, if not found then fetch from API
  Future<void> loadBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('hadith_books');

      if (cachedData != null) {
        // ✅ Load cached data
        final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
        final localBooks = Hadithnamesss.fromJson(jsonMap);
        setState(() {
          booksList = localBooks.books ?? [];
          isLoading = false;
        });
      } else {
        // ✅ Fetch from API first time only
        await fetchAndCacheBooks();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Fetch from API and save to SharedPreferences
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

        // ✅ Save full JSON to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('hadith_books', jsonEncode(jsonData));

        setState(() {
          booksList = booksData.books ?? [];
          isLoading = false;
        });
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
  //for downloading
  bool isDownloaded = false;
  bool isDownloading = false;
  Map<String, String> urduBookNames = {
    "sahih-bukhari": "صحیح بخاری",
    "sahih-muslim": "صحیح مسلم",
    "al-tirmidhi": "جامع الترمذی",
    "abu-dawood": "سنن ابوداؤد",
    "ibn-e-majah": "ابن ماجہ",
    "sunan-nasai": "سنن نسائی",
  };

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
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
                  automaticIndicatorColorAdjustment: true,
                  controller: _controller,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(color: Colors.green),

                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,

                  unselectedLabelColor: Colors.black,
                  padding: EdgeInsets.zero,
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
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : hasError && booksList.isEmpty
                      ? const Center(child: Text("No Internet Connection"))
                      : booksList.isEmpty
                      ? const Center(child: Text("No Hadith books found"))
                      : ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            // final book = booksList[index];
                            final book = index < booksList.length
                                ? booksList[index]
                                : null;

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
                                    onTap: book != null
                                        ? () {
                                            if (book.bookSlug ==
                                                "sahih-bukhari") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Bukhari(title: ''),
                                                ),
                                              );
                                            } else if (book.bookSlug ==
                                                "sahih-muslim") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SahihMuslimChaptersss(),
                                                ),
                                              );
                                            } else if (book.bookSlug ==
                                                "al-tirmidhi") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TirmidhiChapterDetails(),
                                                ),
                                              );
                                            } else if (book.bookSlug ==
                                                "abu-dawood") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SunanChapterDetails(),
                                                ),
                                              );
                                            } else if (book.bookSlug ==
                                                "ibn-e-majah") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      IbneMajah(),
                                                ),
                                              );
                                            } else if (book.bookSlug ==
                                                "sunan-nasai") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SunanChaptersss(),
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    trailing: book != null
                                        ? SizedBox(
                                            width: width * 0.20,

                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed:
                                                      isDownloading ||
                                                          isDownloaded
                                                      ? null
                                                      : () async {
                                                          setState(
                                                            () =>
                                                                isDownloading =
                                                                    true,
                                                          );

                                                          try {
                                                            // Download Sahi Bukhari
                                                            await DownloadSahiBukhar()
                                                                .downloadbook();

                                                            // Check if download succeeded
                                                            final dir =
                                                                await getApplicationDocumentsDirectory();
                                                            final file = File(
                                                              "${dir.path}/sahi-bukhari.json",
                                                            );

                                                            setState(() {
                                                              isDownloaded = file
                                                                  .existsSync();
                                                              isDownloading =
                                                                  false;
                                                            });

                                                            if (isDownloaded) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "Sahi Bukhari Downloaded Successfully",
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            setState(
                                                              () =>
                                                                  isDownloading =
                                                                      false,
                                                            );
                                                            print(
                                                              "Download error: $e",
                                                            );
                                                          }
                                                        },
                                                  icon: isDownloading
                                                      ? SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: Colors
                                                                    .green,
                                                                strokeWidth: 2,
                                                              ),
                                                        )
                                                      : isDownloaded
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
                                          )
                                        : null,
                                    title: book != null
                                        ? Text(
                                            book.bookName ?? "",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: namecolors[index],
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  //////////////////////
                  ///
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : hasError
                      ? const Center(child: Text("No Internet Connection"))
                      : booksList.isEmpty
                      ? const Center(child: Text("No Hadith books found"))
                      : ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final book = booksList[index];
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
                                      if (book.bookSlug == "sahih-bukhari") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BukhariUrdu(title: ''),
                                          ),
                                        );
                                      } else if (book.bookSlug ==
                                          "sahih-muslim") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SahihMuslimChaptersssUrdu(),
                                          ),
                                        );
                                      } else if (book.bookSlug ==
                                          "al-tirmidhi") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TirmidhiChapterDetailsUrdu(),
                                          ),
                                        );
                                      } else if (book.bookSlug ==
                                          "abu-dawood") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SunanChapterDetailsUrdu(),
                                          ),
                                        );
                                      } else if (book.bookSlug ==
                                          "ibn-e-majah") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                IbneMajahUrdu(),
                                          ),
                                        );
                                      } else if (book.bookSlug ==
                                          "sunan-nasai") {
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
                                      urduBookNames[book.bookSlug ?? ""] ??
                                          book.bookName ??
                                          "",
                                      style: TextStyle(
                                        fontFamily: AppFonts.urdufont,
                                        fontSize: 22,
                                        color: namecolors[index],
                                      ),
                                    ),
                                    title: Text(
                                      book.chaptersCount ?? "",
                                      style: const TextStyle(fontSize: 18),
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
      onWillPop: () async {
        return false;
      },
    );
  }
}
