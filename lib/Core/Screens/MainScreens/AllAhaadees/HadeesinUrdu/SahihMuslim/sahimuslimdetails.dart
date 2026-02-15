import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/english_share_screen.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/onmobile_search.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/search_ahadees.dart';
import 'package:muslim/Data/Models/Sahhihmuslim/hadihtdetailmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SahimuslimdetailsUrdu extends StatefulWidget {
  final String? ChapterIds;
  const SahimuslimdetailsUrdu({super.key, this.ChapterIds});

  @override
  State<SahimuslimdetailsUrdu> createState() => _SahimuslimdetailsUrduState();
}

class _SahimuslimdetailsUrduState extends State<SahimuslimdetailsUrdu> {
  List<Data> hadithList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      getHadiths();
    } else {
      loadHadithData();
    }
  }

  Future<void> loadHadithData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'sahih_muslim_hadith_${widget.ChapterIds ?? "all"}';

      // 🔹 Step 1: Load Cached Data (if available)
      final cachedData = prefs.getString(key);
      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        final cachedHadith = SahiMuslimModel.fromJson(decoded);
        setState(() {
          hadithList = cachedHadith.hadiths?.data ?? [];
          isLoading = false;
        });
      }

      // 🔹 Step 2: Always Try to Fetch Latest Data from API
      final chapterQuery = widget.ChapterIds != null
          ? "&chapter=${widget.ChapterIds}"
          : "";

      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/hadiths/?book=sahih-muslim&apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte$chapterQuery",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(key, jsonEncode(data)); // ✅ Save Offline
        final hadithData = SahiMuslimModel.fromJson(data);
        setState(() {
          hadithList = hadithData.hadiths?.data ?? [];
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      debugPrint("⚠️ Error loading data: $e");
      if (hadithList.isEmpty) {
        if (!mounted) return;
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
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
            hadithList = fetchedList.map((h) => Data.fromJson(h)).toList();
            isLoading = false;
          });
          print("Data Loaded: ${hadithList.length} hadiths");
        }
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void showCopyBottomSheet(Data item) {
    int selectedCopy = 1; // default Arabic

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

                  // ---------- Arabic Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Arabic", style: TextStyle(fontSize: 18)),
                      Radio(
                        value: 1,
                        groupValue: selectedCopy,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            selectedCopy = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // ---------- Urdu Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Urdu", style: TextStyle(fontSize: 18)),
                      Radio(
                        value: 2,
                        groupValue: selectedCopy,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            selectedCopy = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // ---------- BOTH Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Both (Arabic + Urdu)",
                        style: TextStyle(fontSize: 18),
                      ),
                      Radio(
                        value: 3,
                        groupValue: selectedCopy,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setStateBottom(() {
                            selectedCopy = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------- COPY BUTTON ----------
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      String textToCopy = "";

                      if (selectedCopy == 1) {
                        textToCopy = item.hadithArabic ?? "";
                      } else if (selectedCopy == 2) {
                        textToCopy = item.hadithUrdu ?? "";
                      } else {
                        textToCopy =
                            "${item.hadithArabic ?? ""}\n\n${item.hadithUrdu ?? ""}";
                      }

                      await Clipboard.setData(ClipboardData(text: textToCopy));

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

  //
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
                    " ${item.hadithNumber} حدیث #",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  // ---------- Arabic Option ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("عربی", style: TextStyle(fontSize: 18)),
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
                      Text("اردو", style: TextStyle(fontSize: 18)),
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
                        "دونوں (عربی + اردو)",
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
                          ? (item.hadithUrdu ?? "")
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
                      "ڈیزائن اور شیئر کریں۔", // Button ka naam change kar diya taake user ko pata chale
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "منسوخ کریں",
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
    return Scaffold(
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
                      MaterialPageRoute(builder: (context) => SearchAhadees()),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : hasError
          ? const Center(child: Text("No Internet Connection ❌"))
          : hadithList.isEmpty
          ? const Center(child: Text("No Hadiths found"))
          : ListView.builder(
              itemCount: hadithList.length,
              itemBuilder: (context, index) {
                final item = hadithList[index];
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
                          if (item.urduNarrator != null)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SelectableText(
                                  item.urduNarrator!,
                                  style: TextStyle(
                                    fontFamily: AppFonts.urdufont,
                                    fontSize: 20,
                                    color: Color(0Xff7851A9),
                                    height: 2.2,
                                  ),
                                ),
                              ),
                            ),

                          const Gap(25),
                          if (item.hadithUrdu != null)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: SelectableText(
                                item.hadithUrdu!,
                                style: TextStyle(
                                  fontFamily: AppFonts.urdufont,
                                  fontSize: 20,
                                  height: 2.0,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          const Gap(10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Status : ${item.status ?? 'Unknown'}"),
                                Text("Hadith No : ${item.hadithNumber ?? '-'}"),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showCopyBottomSheet(
                                    item,
                                  ); // opens copy bottom sheet
                                },
                                icon: const Icon(Icons.copy),
                              ),

                              //                               IconButton(
                              //                                 onPressed: () async {
                              //                                   final hadeesText =
                              //                                       """
                              // Hadith No: ${item.hadithNumber}
                              // Status: ${item.status}

                              // Arabic:
                              // ${item.hadithArabic}

                              // English Translation:
                              // ${item.hadithEnglish}

                              // 🌙 Shared via muslim App – Be Connected with Allah
                              // """;
                              //                                   await Clipboard.setData(
                              //                                     ClipboardData(text: hadeesText),
                              //                                   );
                              //                                   ScaffoldMessenger.of(context).showSnackBar(
                              //                                     const SnackBar(
                              //                                       content: Text(
                              //                                         "Hadith copied to clipboard ✅",
                              //                                       ),
                              //                                       duration: Duration(seconds: 2),
                              //                                     ),
                              //                                   );
                              //                                 },
                              //                                 icon: const Icon(Icons.copy),
                              //                               ),
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
    );
  }
}
