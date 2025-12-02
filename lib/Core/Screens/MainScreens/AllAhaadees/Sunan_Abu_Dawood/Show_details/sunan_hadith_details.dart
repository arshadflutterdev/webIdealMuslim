import 'dart:convert';
import 'package:Muslim/Core/Const/app_fonts.dart';
import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/Sunan_Abu_Dawood/Models/hadithdetailsmodel.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunanHadithDetails extends StatefulWidget {
  final String? chapterno;
  const SunanHadithDetails({super.key, this.chapterno});

  @override
  State<SunanHadithDetails> createState() => _SunanHadithDetailsState();
}

class _SunanHadithDetailsState extends State<SunanHadithDetails> {
  List<Data> hadithList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadHadithData();
  }

  Future<void> loadHadithData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'sunan_hadith_${widget.chapterno ?? "all"}';

    // Load cached data first
    final cachedData = prefs.getString(key);
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        final cachedHadith = SunanHadithsDetails.fromJson(decoded);
        setState(() {
          hadithList = cachedHadith.hadiths?.data ?? [];
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Error decoding cached data: $e");
      }
    }

    // Fetch latest data from API
    try {
      final chapternum = widget.chapterno != null
          ? "&chapter=${widget.chapterno}"
          : "";
      final response = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/hadiths/?book=abu-dawood&apiKey=\$2y\$10\$pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte$chapternum",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(key, jsonEncode(data)); // save latest data
        final hadithData = SunanHadithsDetails.fromJson(data);
        setState(() {
          hadithList = hadithData.hadiths?.data ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("No data found from API");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (hadithList.isEmpty) {
        if (!mounted) return;
        setState(() {
          hasError = true;
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
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : hasError
            ? const Center(child: Text("No Internet Connection"))
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
                              SelectableText(
                                item.englishNarrator!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
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
        AdController().tryShowAd();
        Navigator.pop(context);

        return false;
      },
    );
  }
}
