import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithdetailsUrdu extends StatefulWidget {
  final String? ChapterId;
  const HadithdetailsUrdu({super.key, this.ChapterId});

  @override
  State<HadithdetailsUrdu> createState() => _HadithdetailsUrduState();
}

class _HadithdetailsUrduState extends State<HadithdetailsUrdu> {
  List<Data> hadithList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHadithData();
  }

  Future<void> loadHadithData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'hadith_${widget.ChapterId ?? "all"}';

    final cachedData = prefs.getString(key);
    if (cachedData != null) {
      // Load from local storage first
      final decoded = jsonDecode(cachedData);
      final cachedHadith = HadithDetails.fromJson(decoded);
      setState(() {
        hadithList = cachedHadith.hadiths?.data ?? [];
        isLoading = false;
      });
    }

    try {
      // Then fetch latest data from API
      final chapterQuery = widget.ChapterId != null
          ? "&chapter=${widget.ChapterId}"
          : "";
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/hadiths/?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte$chapterQuery",
        ),
      );

      if (response.statusCode == 200) {
        final dataa = jsonDecode(response.body);
        await prefs.setString(key, jsonEncode(dataa)); // Save for next time
        final hadithdata = HadithDetails.fromJson(dataa);

        setState(() {
          hadithList = hadithdata.hadiths?.data ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      if (cachedData == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
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
                        textToShare = item.hadithUrdu ?? "";
                      } else {
                        textToShare =
                            "${item.hadithArabic ?? ""}\n\n${item.hadithUrdu ?? ""}";
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
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hadithList.isEmpty
            ? const Center(child: Text("No Internet Connection"))
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
                                  item.hadithArabic ?? 'no text',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: AppFonts.arabicfont,
                                    fontSize: 25,
                                    height: 2,
                                    wordSpacing: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const Gap(25),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: SelectableText(
                                item.urduNarrator ?? "",
                                style: TextStyle(
                                  fontFamily: AppFonts.urdufont,
                                  color: Colors.black,
                                  fontSize: 20,
                                  height: 2.2,
                                ),
                              ),
                            ),

                            const Gap(25),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: SelectableText(
                                item.hadithUrdu ?? "",
                                style: TextStyle(
                                  fontFamily: AppFonts.urdufont,
                                  fontSize: 18,
                                  wordSpacing: 3,
                                  height: 2.3,
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
                                  Text("Status : ${item.status}"),
                                  Text("Hadith No : ${item.hadithNumber}"),
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
${item.headingEnglish}

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
