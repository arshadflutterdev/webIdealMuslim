import 'dart:convert';
import 'dart:io';
import 'package:muslim/Core/Const/app_fonts.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SunanAnNasai/Models/sunananasai_detailed_model.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunananasaiHadithDetailsUrdu extends StatefulWidget {
  final String? chapterno;
  const SunananasaiHadithDetailsUrdu({super.key, this.chapterno});

  @override
  State<SunananasaiHadithDetailsUrdu> createState() =>
      _SunananasaiHadithDetailsUrduState();
}

class _SunananasaiHadithDetailsUrduState
    extends State<SunananasaiHadithDetailsUrdu> {
  bool isLoading = true;
  bool hasError = false;
  List<Data> haditsss = [];
  Future<void> getdownloadhadith() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sunan-nasai.json");

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
      final filteredHadiths = widget.chapterno == null
          ? allHadiths
          : allHadiths.where((h) => h.chapterId == widget.chapterno).toList();

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

  void showCopyBottomSheet(Data item) {
    int selected = 1; // default Arabic

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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hadith # ${item.hadithNumber}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Arabic Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Arabic", style: TextStyle(fontSize: 18)),
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

                  // Urdu Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Urdu", style: TextStyle(fontSize: 18)),
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

                  // Both Option
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
                      String textToCopy;

                      if (selected == 1) {
                        textToCopy = item.hadithArabic ?? '';
                      } else if (selected == 2) {
                        textToCopy = item.hadithUrdu ?? '';
                      } else {
                        textToCopy =
                            "${item.hadithArabic ?? ''}\n\n${item.hadithUrdu ?? ''}";
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
  void initState() {
    super.initState();
    getdownloadhadith();
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
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text("No Internet ❌"))
            : haditsss.isEmpty
            ? const Center(child: Text("No data available"))
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
                                      color: Color(0Xff7851A9),
                                    ),
                                  ),
                                ),
                              ),
                            const Gap(10),
                            if (item.hadithUrdu != null)
                              Directionality(
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
                                    ); // opens interactive copy options
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
        Navigator.pop(context);
        AdController().tryShowAd();
        return false;
      },
    );
  }
}
