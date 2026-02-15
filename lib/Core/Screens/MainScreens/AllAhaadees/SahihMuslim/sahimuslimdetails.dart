import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/english_share_screen.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Data/Models/Sahhihmuslim/hadihtdetailmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class Sahimuslimdetails extends StatefulWidget {
  final String? ChapterIds;
  const Sahimuslimdetails({super.key, this.ChapterIds});

  @override
  State<Sahimuslimdetails> createState() => _SahimuslimdetailsState();
}

class _SahimuslimdetailsState extends State<Sahimuslimdetails> {
  List<Data> haditsss = [];
  bool isLoading = false;
  bool hasError = false;
  Future<void> getdownloadhadith() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-muslim.json");

      if (!file.existsSync()) {
        print("Offline data file not found!");
        setState(() {
          haditsss = [];
          isLoading = false;
        });
        return;
      }

      final fileContent = await file.readAsString();
      final filedecode = jsonDecode(fileContent);

      // filedecode["chapters"] should be a List
      final chapters = filedecode["chapters"];
      List<Data> allHadiths = [];

      if (chapters != null && chapters is List) {
        for (var chapter in chapters) {
          final hadithMap = chapter["hadiths"];
          if (hadithMap != null && hadithMap is Map<String, dynamic>) {
            final hadithList = hadithMap["data"];
            if (hadithList != null && hadithList is List) {
              for (var h in hadithList) {
                allHadiths.add(Data.fromJson(h));
              }
            }
          }
        }
      }

      // Filter by ChapterId if provided
      final filteredHadiths = widget.ChapterIds == null
          ? allHadiths
          : allHadiths.where((h) => h.chapterId == widget.ChapterIds).toList();

      setState(() {
        haditsss = filteredHadiths;
        isLoading = false;
      });

      print("Total hadiths loaded: ${haditsss.length}");
    } catch (e) {
      print("Error loading hadiths offline: ${e.toString()}");
      setState(() {
        haditsss = [];
        isLoading = false;
      });
    }
  }

  final String apiUrl = "https://hadith-proxy-mpc6.vercel.app/muslim-hadiths";

  Future<void> getHadiths() async {
    setState(() => isLoading = true);

    // 2. URL mein Chapter ID add karein taake wahi data aaye jo chahiye
    final String finalUrl = "$apiUrl?chapter=${widget.ChapterIds}";
    try {
      print("Fetching from: $finalUrl");
      final response = await http.get(Uri.parse(finalUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        // API response mein 'hadiths' ke andar 'data' hota hai
        if (decodedData['hadiths'] != null &&
            decodedData['hadiths']['data'] != null) {
          final List<dynamic> fetchedList = decodedData['hadiths']['data'];

          setState(() {
            // Ab filter lagane ki zaroorat nahi, API khud filter karke degi
            haditsss = fetchedList.map((h) => Data.fromJson(h)).toList();
            isLoading = false;
          });
          print("Data Loaded: ${haditsss.length} hadiths");
        }
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      getHadiths();
    } else {
      getdownloadhadith();
    }
  }

  //here is function for copy
  void showCopyBottomSheet(Data item) {
    int copySelected = 1;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Copy Hadith # ${item.hadithNumber ?? ''}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Arabic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Arabic", style: TextStyle(fontSize: 18)),
                      Radio(
                        value: 1,
                        groupValue: copySelected,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            copySelected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // English
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("English", style: TextStyle(fontSize: 18)),
                      Radio(
                        value: 2,
                        groupValue: copySelected,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            copySelected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // Both
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Both (Arabic + English)",
                        style: TextStyle(fontSize: 18),
                      ),
                      Radio(
                        value: 3,
                        groupValue: copySelected,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            copySelected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // COPY BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      String copyText = "";

                      if (copySelected == 1) {
                        copyText = item.hadithArabic ?? "";
                      } else if (copySelected == 2) {
                        copyText = item.hadithEnglish ?? "";
                      } else {
                        copyText =
                            "${item.hadithArabic ?? ""}\n\n${item.hadithEnglish ?? ""}";
                      }

                      await Clipboard.setData(ClipboardData(text: copyText));

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hadith copied to clipboard ✅"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      "Copy",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 18, color: Colors.black38),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int selected = 1;
  void showbottom(Data item) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Hadith # ${item.hadithNumber}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  // ---------- Arabic Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Arabic", style: TextStyle(fontSize: 18)),
                      Radio(
                        activeColor: Colors.green,
                        value: 1,
                        groupValue: selected,
                        onChanged: (value) {
                          setState(() {
                            selected = value!;
                          });
                          setStateBottom(() {
                            selected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // ---------- English Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("English", style: TextStyle(fontSize: 18)),
                      Radio(
                        activeColor: Colors.green,
                        value: 2,
                        groupValue: selected,
                        onChanged: (value) {
                          setState(() {
                            selected = value!;
                          });
                          setStateBottom(() {
                            selected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // ---------- BOTH Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Both (Arabic + English)",
                        style: TextStyle(fontSize: 18),
                      ),
                      Radio(
                        activeColor: Colors.green,
                        value: 3,
                        groupValue: selected,
                        onChanged: (value) {
                          setState(() {
                            selected = value!;
                          });
                          setStateBottom(() {
                            selected = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ---------- SHARE BUTTON ----------
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // 1. Pehle Bottom Sheet ko band karein
                      Navigator.pop(context);

                      // 2. Data prepare karein jo humne agli screen par bhejna hai
                      // Hum user ki choice (Arabic, English ya Both) ke mutabiq data bhejenge
                      String arabicData = (selected == 1 || selected == 3)
                          ? (item.hadithArabic ?? "")
                          : "";
                      String englishData = (selected == 2 || selected == 3)
                          ? (item.hadithEnglish ?? "")
                          : "";

                      // 3. Design wali screen par move karein
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnglishShareScreen(
                            arabic: arabicData,
                            english: englishData,
                            hadithNo: item.hadithNumber.toString(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Design & Share", // Button ka naam change kar diya taake user ko pata chale
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return WillPopScope(
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

          backgroundColor: Colors.white,
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
            : haditsss.isEmpty
            ? const Center(child: Text("No Hadiths found"))
            : ListView.builder(
                itemCount: haditsss.length,
                itemBuilder: (context, index) {
                  final item = haditsss[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: SelectableText(
                                  item.hadithArabic ?? 'No Arabic text',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: AppFonts.arabicfont,
                                    height: 2,
                                    fontSize: 25,
                                    wordSpacing: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(25),
                            if (item.englishNarrator != null)
                              SelectableText(
                                item.englishNarrator!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0Xff7851A9),
                                ),
                              ),

                            const Gap(25),
                            if (item.hadithEnglish != null)
                              SelectableText(
                                item.hadithEnglish!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Status : ${item.status ?? 'Unknown'}"),
                                  Text(
                                    "Hadith No : ${item.hadithNumber ?? '-'}",
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showCopyBottomSheet(item);
                                  },
                                  icon: const Icon(Icons.copy),
                                ),

                                //                                 IconButton(
                                //                                   onPressed: () async {
                                //                                     final hadeesText =
                                //                                         """
                                // Hadith No: ${item.hadithNumber}
                                // Status: ${item.status}

                                // Arabic:
                                // ${item.hadithArabic}

                                // English Translation:
                                // ${item.hadithEnglish}

                                // 🌙 Shared via muslim App – Be Connected with Allah
                                // """;
                                //                                     await Clipboard.setData(
                                //                                       ClipboardData(text: hadeesText),
                                //                                     );
                                //                                     ScaffoldMessenger.of(context).showSnackBar(
                                //                                       const SnackBar(
                                //                                         content: Text(
                                //                                           "Hadith copied to clipboard ✅",
                                //                                         ),
                                //                                         duration: Duration(seconds: 2),
                                //                                       ),
                                //                                     );
                                //                                   },

                                //                                   icon: const Icon(Icons.copy),
                                //                                 ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    showbottom(item);
                                  },
                                  icon: const Icon(Icons.share),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      onWillPop: () async {
        AdController().tryShowAd();
        Navigator.pop(context);
        return false;
      },
    );
  }
}
