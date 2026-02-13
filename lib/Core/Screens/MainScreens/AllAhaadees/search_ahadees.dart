import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
// Apne models ka sahi path yahan likhein
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> allHadithsList = []; // Tamam books ka data
  List<Data> searchResults = []; // Filtered data
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAllBooksData();
  }

  // 1. Saari files ko ek sath load karne wala function
  Future<void> loadAllBooksData() async {
    setState(() => isLoading = true);

    List<String> fileNames = [
      "sahih-bukhari.json",
      "sahih-muslim.json",
      "al-tirmidhi.json",
      "abu-dawood.json",
      "ibn-e-majah.json",
      "sunan-nasai.json",
    ];

    try {
      final dir = await getApplicationDocumentsDirectory();
      List<Data> tempAllHadiths = [];

      for (String name in fileNames) {
        final file = File("${dir.path}/$name");
        if (file.existsSync()) {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);
          final chapters = decoded["chapters"];

          if (chapters != null && chapters is List) {
            for (var chapter in chapters) {
              final hadithData = chapter["hadiths"]?["data"];
              if (hadithData is List) {
                for (var h in hadithData) {
                  tempAllHadiths.add(Data.fromJson(h));
                }
              }
            }
          }
        }
      }

      setState(() {
        allHadithsList = tempAllHadiths;
        isLoading = false;
      });
      print("Total Data Loaded: ${allHadithsList.length}");
    } catch (e) {
      print("Error Loading Data: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Search Logic (Number filter)
  void _runFilter(String enteredKeyword) {
    List<Data> results = [];
    if (enteredKeyword.isEmpty) {
      results = [];
    } else {
      results = allHadithsList
          .where(
            (hadith) => hadith.hadithNumber.toString().contains(enteredKeyword),
          )
          .toList();
    }

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          "Search All Hadiths",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Input Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              cursorColor: Colors.black,
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Hadith Number Likhein...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Results Section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _searchController.text.isEmpty
                ? const Center(child: Text("Search Hadits"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];

                      // Arabic Title ko thora short kar dete hain taake screen se bahar na jaye
                      String arabicTitle =
                          (hadith.hadithArabic ?? "").length > 50
                          ? "${hadith.hadithArabic!.substring(0, 50)}..."
                          : (hadith.hadithArabic ?? "");

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          shape:
                              const Border(), // Expansion lines khatam karne ke liye
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 18,
                            child: Text(
                              hadith.hadithNumber.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // --- TITLE: Arabic Text ---
                          title: Text(
                            arabicTitle,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily:
                                  'Arabic', // Agar aapne font add kiya hai
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // --- SUBTITLE: Urdu aur English Mix ---
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Gap(4),
                              // Urdu Preview
                              Text(
                                hadith.hadithUrdu ??
                                    "Urdu translation not available",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // English Preview
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  hadith.hadithEnglish ?? "",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          childrenPadding: const EdgeInsets.all(15),
                          children: [
                            const Divider(),
                            // Poora Arabic
                            Text(
                              hadith.hadithArabic ?? "",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                height: 1.6,
                                color: Colors.black,
                              ),
                            ),
                            const Gap(15),

                            // Urdu Full Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                hadith.hadithUrdu ?? "",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            const Gap(15),

                            // English Full Section
                            Text(
                              hadith.hadithEnglish ?? "",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),

                            const Gap(10),
                            // Actions: Copy/Share (Optional)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
