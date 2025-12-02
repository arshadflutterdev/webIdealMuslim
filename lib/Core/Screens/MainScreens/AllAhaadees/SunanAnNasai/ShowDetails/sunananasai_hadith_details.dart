import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/Models/sunananasai_detailed_model.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunananasaiHadithDetails extends StatefulWidget {
  final String? chapterno;
  const SunananasaiHadithDetails({super.key, this.chapterno});

  @override
  State<SunananasaiHadithDetails> createState() =>
      _SunananasaiHadithDetailsState();
}

class _SunananasaiHadithDetailsState extends State<SunananasaiHadithDetails> {
  bool isLoading = true;
  bool hasError = false;
  List<Data> hadithList = [];

  @override
  void initState() {
    super.initState();
    loadHadithData();
  }

  Future<void> loadHadithData() async {
    final prefs = await SharedPreferences.getInstance();

    final cacheKey = "sunan_nasai_chapter_${widget.chapterno}";

    // 🔹 1) Load Cached Data
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        final model = SunanAnNasaiHadithDetails.fromJson(decoded);

        setState(() {
          hadithList = model.hadiths?.data ?? [];
          isLoading = false;
          hasError = false;
        });

        print("📌 Loaded hadith details from CACHE");
        return; // 🔥 Skip API request
      } catch (e) {
        print("Cache parse error: $e");
      }
    }

    // 🔹 2) Fetch From API (only if cache not available)
    try {
      final chapterQuery = widget.chapterno != null
          ? "&chapter=${widget.chapterno}"
          : "";

      final url =
          "https://hadithapi.com/api/hadiths/?book=sunan-nasai&apiKey=\$2y\$10\$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte$chapterQuery";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save to cache
        await prefs.setString(cacheKey, jsonEncode(data));

        final model = SunanAnNasaiHadithDetails.fromJson(data);

        setState(() {
          hadithList = model.hadiths?.data ?? [];
          isLoading = false;
          hasError = false;
        });

        print("🌍 Loaded hadith details from API + Cached");
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Network Error: $e");
      if (mounted)
        setState(() {
          isLoading = false;
          hasError = true;
        });
    }
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
                      String textToShare;

                      if (selected == 1) {
                        textToShare = item.hadithArabic ?? "";
                      } else if (selected == 2) {
                        textToShare = item.hadithEnglish ?? "";
                      } else {
                        textToShare =
                            "${item.hadithArabic ?? ""}\n\n${item.hadithEnglish ?? ""}";
                      }

                      Share.share(textToShare);
                    },
                    child: const Text(
                      "Share",
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
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text("No Internet ❌"))
            : hadithList.isEmpty
            ? const Center(child: Text("No data available"))
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
                            if (item.englishNarrator != null)
                              Align(
                                alignment: Alignment.topLeft,
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: SelectableText(
                                    item.englishNarrator!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      height: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            const Gap(10),
                            if (item.hadithEnglish != null)
                              Align(
                                alignment: Alignment.topLeft,
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: SelectableText(
                                    item.hadithEnglish!,
                                    style: TextStyle(
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
                                  onPressed: () async {
                                    final hadeesText =
                                        """
Hadith No: ${item.hadithNumber}
Status: ${item.status}

Arabic:
${item.hadithArabic}

English Translation:
${item.hadithEnglish}

🌙 Shared via Muslim App – Be Connected with Allah
""";
                                    await Clipboard.setData(
                                      ClipboardData(text: hadeesText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Hadith copied to clipboard ✅",
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                ),
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
