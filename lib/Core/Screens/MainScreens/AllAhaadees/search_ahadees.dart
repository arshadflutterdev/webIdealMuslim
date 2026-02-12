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
                : searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text("Koi Hadith nahi mili!"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            child: Text(
                              hadith.hadithNumber.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            "Hadith Number: ${hadith.hadithNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Click karke detail dekhein",
                            style: TextStyle(fontSize: 11),
                          ),
                          childrenPadding: const EdgeInsets.all(15),
                          expandedAlignment: Alignment.topRight,
                          children: [
                            // Arabic
                            Text(
                              hadith.hadithArabic ?? "",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 20,
                                height: 1.6,
                                color: Colors.black,
                                fontFamily: 'Arabic',
                              ),
                            ),
                            const Divider(),
                            // Urdu (Agar aapke model mein field ka naam 'hadithUrdu' hai)
                            Text(
                              hadith.hadithUrdu ??
                                  "Urdu translation not available",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(10),
                            // English
                            Text(
                              hadith.hadithEnglish ?? "",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
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
