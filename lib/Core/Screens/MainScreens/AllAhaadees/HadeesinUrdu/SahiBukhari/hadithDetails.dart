import 'dart:convert';
import 'dart:io';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithdetailsUrdu extends StatefulWidget {
  final String? ChapterId;
  const HadithdetailsUrdu({super.key, this.ChapterId});

  @override
  State<HadithdetailsUrdu> createState() => _HadithdetailsUrduState();
}

class _HadithdetailsUrduState extends State<HadithdetailsUrdu> {
  List<Data> haditsss = [];
  bool isLoading = true;
  Future<void> getdownloadhadith() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-bukhari.json");

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
      final filteredHadiths = widget.ChapterId == null
          ? allHadiths
          : allHadiths.where((h) => h.chapterId == widget.ChapterId).toList();

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

  @override
  void initState() {
    super.initState();
    getdownloadhadith();
  }

  void showCopyBottom(Data item) {
    int selectedCopy = 1; // default Arabic

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Hadith # ${item.hadithNumber}",
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
                        activeColor: Colors.green,
                        value: 1,
                        groupValue: selectedCopy,
                        onChanged: (value) {
                          setState(() {
                            selectedCopy = value!;
                          });
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
                        activeColor: Colors.green,
                        value: 2,
                        groupValue: selectedCopy,
                        onChanged: (value) {
                          setState(() {
                            selectedCopy = value!;
                          });
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
                        activeColor: Colors.green,
                        value: 3,
                        groupValue: selectedCopy,
                        onChanged: (value) {
                          setState(() {
                            selectedCopy = value!;
                          });
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
                    onPressed: () {
                      String textToCopy;

                      if (selectedCopy == 1) {
                        textToCopy = item.hadithArabic ?? "";
                      } else if (selectedCopy == 2) {
                        textToCopy = item.hadithUrdu ?? "";
                      } else {
                        textToCopy =
                            "Hadith No: ${item.hadithNumber}\nStatus: ${item.status}\n\nArabic:\n${item.hadithArabic}\n\nUrdu Translation:\n${item.hadithUrdu}\n\n🌙 Shared via Muslim App – Be Connected with Allah";
                      }

                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hadith copied to clipboard ✅"),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      Navigator.pop(context); // close bottom sheet
                    },
                    child: const Text(
                      "Copy",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
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
            : haditsss.isEmpty
            ? const Center(child: Text("No Internet Connection"))
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
                                  color: Color(0Xff7851A9),
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
                                  onPressed: () {
                                    showCopyBottom(
                                      item,
                                    ); // opens the copy bottom sheet
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
                                // ${item.headingEnglish}

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
        Navigator.pop(context);
        AdController().tryShowAd();
        return false;
      },
    );
  }
}
