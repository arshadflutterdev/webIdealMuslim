import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/Jami_Al-Tirmidhi/Models/tirmidhi_details_model.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/english_share_screen.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TirmidhiDetailsUrdu extends StatefulWidget {
  final String? chapterId;
  const TirmidhiDetailsUrdu({super.key, this.chapterId});

  @override
  State<TirmidhiDetailsUrdu> createState() => _TirmidhiDetailsUrduState();
}

class _TirmidhiDetailsUrduState extends State<TirmidhiDetailsUrdu> {
  List<Data> haditsss = [];
  bool isLoading = true;
  bool hasError = false;
  Future<void> getdownloadhadith() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/al-tirmidhi.json");

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
      final filteredHadiths = widget.chapterId == null
          ? allHadiths
          : allHadiths.where((h) => h.chapterId == widget.chapterId).toList();

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

  final String apiUrl = "https://hadith-proxy-mpc6.vercel.app/tirmidhi-hadiths";

  Future<void> getHadiths() async {
    setState(() => isLoading = true);

    // 2. URL mein Chapter ID add karein taake wahi data aaye jo chahiye
    final String finalUrl = "$apiUrl?chapter=${widget.chapterId}";
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

  // 🔹 Reusable function for copying or sharing Hadith text
  String formatHadithText(Data item) {
    return """
Hadith No: ${item.hadithNumber}
Status: ${item.status}

Arabic:
${item.hadithArabic ?? 'N/A'}




English Translation:
${item.hadithEnglish ?? 'N/A'}

🌙 Shared via Muslim App – Be Connected with Allah
""";
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
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
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
            ? const Center(child: Text("No hadith found"))
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
                                    fontSize: 25,
                                    wordSpacing: 2,
                                    height: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(25),
                            if (item.urduNarrator != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SelectableText(
                                    item.urduNarrator!,
                                    style: TextStyle(
                                      fontFamily: AppFonts.urdufont,
                                      fontSize: 20,
                                      height: 2.2,
                                      color: Color(0Xff7851A9),
                                    ),
                                  ),
                                ),
                              ),
                            const Gap(25),
                            if (item.hadithUrdu != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SelectableText(
                                    item.hadithUrdu!,
                                    style: TextStyle(
                                      fontFamily: AppFonts.urdufont,
                                      fontSize: 20,
                                      height: 2,
                                      color: Colors.green,
                                    ),
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
                                    showCopyBottomSheet(
                                      item,
                                    ); // opens the new copy bottom sheet
                                  },
                                  icon: const Icon(Icons.copy),
                                ),

                                // IconButton(
                                //   onPressed: () async {
                                //     final text = formatHadithText(item);
                                //     await Clipboard.setData(
                                //       ClipboardData(text: text),
                                //     );
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       const SnackBar(
                                //         content: Text(
                                //           "Hadith copied to clipboard ✅",
                                //         ),
                                //         duration: Duration(seconds: 2),
                                //       ),
                                //     );
                                //   },
                                //   icon: const Icon(Icons.copy),
                                // ),
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
        Navigator.pop(context);
        AdController().tryShowAd();
        return false;
      },
    );
  }
}
