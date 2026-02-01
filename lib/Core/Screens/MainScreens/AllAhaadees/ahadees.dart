// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/sahibukhari.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahihMuslim/sahih_muslim_chapters.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';
import 'package:muslim/Core/Screens/books_download.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Jami_Al-Tirmidhi/DetailScreens/tirmidhi_chapter_details.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/sahibukhari.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sahihmuslim/sahih_muslim_chapters.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SunanAnNasai/ShowDetails/sunan_chapters.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Abu_Dawood/Show_details/chapterdetails.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/Sunan_Ibn_e_Majah/ShowDetails/majah_chapter_details.dart';

import 'package:muslim/Data/Models/ahadeesmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    downloadService.addListener(_refreshUI);

    loadBooks();
  }

  void _refreshUI() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    downloadService.removeListener(_refreshUI);
    _controller.dispose();
    super.dispose();
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
        for (final b in booksList) {
          downloadService.checkDownloaded(b.bookSlug ?? "");
        }
        // checkAllDownloads();
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

        // checkAllDownloads();
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

  // 1. Update the handleBookTap to be web-safe
  void handleBookTap({required String slug, required bool isUrdu}) async {
    // Only check local files if NOT on Web
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$slug.json");
      if (!file.existsSync()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUrdu
                  ? "پہلے حدیث ڈاؤن لوڈ کریں"
                  : "Please download hadith first",
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    // Define the target Screen
    Widget targetScreen;

    if (!isUrdu) {
      switch (slug) {
        case "sahih-bukhari":
          targetScreen = const Bukhari(title: '');
          break;
        case "sahih-muslim":
          targetScreen = const SahihMuslimChaptersss();
          break;
        case "al-tirmidhi":
          targetScreen = const TirmidhiChapterDetails();
          break;
        case "abu-dawood":
          targetScreen = const SunanChapterDetails();
          break;
        case "ibn-e-majah":
          targetScreen = const IbneMajah();
          break;
        case "sunan-nasai":
          targetScreen = const SunanChaptersss();
          break;
        default:
          return;
      }
    } else {
      switch (slug) {
        case "sahih-bukhari":
          targetScreen = const BukhariUrdu(title: '');
          break;
        case "sahih-muslim":
          targetScreen = const SahihMuslimChaptersssUrdu();
          break;
        case "al-tirmidhi":
          targetScreen = const TirmidhiChapterDetailsUrdu();
          break;
        case "abu-dawood":
          targetScreen = const SunanChapterDetailsUrdu();
          break;
        case "ibn-e-majah":
          targetScreen = const IbneMajahUrdu();
          break;
        case "sunan-nasai":
          targetScreen = const SunanChaptersssUrdu();
          break;
        default:
          return;
      }
    }

    // Use a cleaner navigation call
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => targetScreen));
  }
  // void handleBookTap({required String slug, required bool isUrdu}) async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final file = File("${dir.path}/$slug.json");
  //   if (!kIsWeb) {
  //     if (!file.existsSync()) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             isUrdu
  //                 ? "پہلے حدیث ڈاؤن لوڈ کریں"
  //                 : "Please download hadith first",
  //           ),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   if (!isUrdu) {
  //     if (slug == "sahih-bukhari") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => Bukhari(title: '')),
  //       );
  //     } else if (slug == "sahih-muslim") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SahihMuslimChaptersss()),
  //       );
  //     } else if (slug == "al-tirmidhi") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => TirmidhiChapterDetails()),
  //       );
  //     } else if (slug == "abu-dawood") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SunanChapterDetails()),
  //       );
  //     } else if (slug == "ibn-e-majah") {
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => IbneMajah()));
  //     } else if (slug == "sunan-nasai") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SunanChaptersss()),
  //       );
  //     }
  //   } else {
  //     if (slug == "sahih-bukhari") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => BukhariUrdu(title: '')),
  //       );
  //     } else if (slug == "sahih-muslim") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SahihMuslimChaptersssUrdu()),
  //       );
  //     } else if (slug == "al-tirmidhi") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => TirmidhiChapterDetailsUrdu()),
  //       );
  //     } else if (slug == "abu-dawood") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SunanChapterDetailsUrdu()),
  //       );
  //     } else if (slug == "ibn-e-majah") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => IbneMajahUrdu()),
  //       );
  //     } else if (slug == "sunan-nasai") {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => SunanChaptersssUrdu()),
  //       );
  //     }
  //   }
  // }

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
  final DownloadService downloadService = DownloadService.instance;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFCF8F6),
          title: Text(
            "Hadees",
            style: TextStyle(
              fontSize: 30,
              color: Colors.black54,
              letterSpacing: 3,
              fontFamily: AppFonts.engfont,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFCF8F6),
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
                  indicatorColor: Colors.red,
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
                      : (kIsWeb)
                      ? GridView.builder(
                          itemCount: booksList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 5.5,
                              ),
                          itemBuilder: (context, index) {
                            final book = booksList[index];
                            final slug = book.bookSlug ?? "";
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  handleBookTap(slug: slug, isUrdu: false);
                                },
                                trailing: Text(
                                  overflow: TextOverflow.ellipsis,

                                  book.chaptersCount ?? "",
                                  style: TextStyle(fontSize: height * 0.030),
                                ),
                                title: Text(
                                  book.bookName ?? "",
                                  style: TextStyle(
                                    fontSize: height * 0.030,
                                    color: namecolors[index],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
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
                                height: orientation == Orientation.landscape
                                    ? 65
                                    : height * 0.09,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      handleBookTap(slug: slug, isUrdu: false);
                                    },
                                    trailing: SizedBox(
                                      width: width * 0.20,
                                      child: Row(
                                        children: [
                                          Text(
                                            book.chaptersCount ?? "",
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),

                                          IconButton(
                                            onPressed: () async {
                                              // If already downloading, do nothing
                                              if (downloadService.isDownloading(
                                                slug,
                                              )) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "A download is already in progress. Please wait!",
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // If already downloaded, delete it
                                              if (downloadService.isDownloaded(
                                                slug,
                                              )) {
                                                await downloadService
                                                    .deleteBook(slug);
                                              } else {
                                                DownloadService.instance
                                                    .downloadBook(
                                                      isUrdu: false,
                                                      context,
                                                      slug,
                                                    );
                                              }
                                            },
                                            icon:
                                                downloadService.isDownloading(
                                                  slug,
                                                )
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.green,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : downloadService.isDownloaded(
                                                    slug,
                                                  )
                                                ? const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  )
                                                : const Icon(
                                                    Icons.download,
                                                    color: Colors.black54,
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
                  // Urdu Tab
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : hasError
                      ? const Center(child: Text("No Internet Connection"))
                      : booksList.isEmpty
                      ? const Center(child: Text("No Hadith books found"))
                      : (kIsWeb)
                      ? GridView.builder(
                          itemCount: booksList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6,
                              ),
                          itemBuilder: (context, index) {
                            final book = booksList[index];
                            final slug = book.bookSlug ?? "";
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  handleBookTap(slug: slug, isUrdu: true);
                                },
                                trailing: FittedBox(
                                  child: Center(
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      urduBookNames[slug] ??
                                          book.bookName ??
                                          "",
                                      style: TextStyle(
                                        fontFamily: AppFonts.urdufont,
                                        fontSize: height * 0.040,
                                        color: namecolors[index],
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  book.chaptersCount ?? "",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            );
                          },
                        )
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
                                height: orientation == Orientation.landscape
                                    ? 65
                                    : height * 0.09,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      handleBookTap(slug: slug, isUrdu: true);
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
                                            onPressed: () async {
                                              // If already downloading, do nothing
                                              if (downloadService.isDownloading(
                                                slug,
                                              )) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "ایک ڈاؤن لوڈ پہلے سے جاری ہے، براہ کرم انتظار کریں!",
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // If already downloaded, delete it
                                              if (downloadService.isDownloaded(
                                                slug,
                                              )) {
                                                await downloadService
                                                    .deleteBook(slug);
                                              } else {
                                                // Queue the download instead of calling downloadBook directly
                                                // downloadService.downloadBook(
                                                //   slug,
                                                // );
                                                DownloadService.instance
                                                    .downloadBook(
                                                      isUrdu: true,
                                                      context,
                                                      slug,
                                                    );
                                              }
                                            },
                                            icon:
                                                downloadService.isDownloading(
                                                  slug,
                                                )
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.green,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : downloadService.isDownloaded(
                                                    slug,
                                                  )
                                                ? const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  )
                                                : const Icon(
                                                    Icons.download,
                                                    color: Colors.black54,
                                                  ),
                                          ),

                                          // IconButton(
                                          //   onPressed: () async {
                                          //     if (downloadService.isDownloading(
                                          //       slug,
                                          //     ))
                                          //       return;

                                          //     if (downloadService.isDownloaded(
                                          //       slug,
                                          //     )) {
                                          //       await downloadService
                                          //           .deleteBook(slug);
                                          //     } else {
                                          //       await downloadService
                                          //           .downloadBook(slug);
                                          //     }
                                          //   },

                                          //   icon:
                                          //       downloadService.isDownloading(
                                          //         slug,
                                          //       )
                                          //       ? const SizedBox(
                                          //           width: 24,
                                          //           height: 24,
                                          //           child:
                                          //               CircularProgressIndicator(
                                          //                 color: Colors.green,
                                          //                 strokeWidth: 2,
                                          //               ),
                                          //         )
                                          //       : downloadService.isDownloaded(
                                          //           slug,
                                          //         )
                                          //       ? const Icon(
                                          //           Icons.delete,
                                          //           color: Colors.red,
                                          //         )
                                          //       : const Icon(
                                          //           Icons.download,
                                          //           color: Colors.black54,
                                          //         ),
                                          // ),
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
