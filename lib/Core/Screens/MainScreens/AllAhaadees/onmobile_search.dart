import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
// Apne model ka path confirm kar lena
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> allHadithsList = [];
  List<Data> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAllBooksData();
  }

  // --- DATA LOADING LOGIC ---
  Future<void> loadAllBooksData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    // Ye slugs DownloadService ke exact match hain
    List<String> slugs = [
      "sahih-bukhari",
      "sahih-muslim",
      "al-tirmidhi",
      "abu-dawood",
      "ibn-e-majah",
      "sunan-nasai",
    ];

    try {
      final dir = await getApplicationDocumentsDirectory();
      List<Data> tempAllHadiths = [];

      for (String slug in slugs) {
        final file = File("${dir.path}/$slug.json");

        if (file.existsSync()) {
          final content = await file.readAsString();
          final dynamic decoded = jsonDecode(content);

          // 1. Check: Agar chapters -> hadiths -> data wala format hai
          if (decoded is Map && decoded.containsKey("chapters")) {
            var chapters = decoded["chapters"];
            if (chapters is List) {
              for (var chapter in chapters) {
                var hData = chapter["hadiths"]?["data"];
                if (hData is List) {
                  for (var h in hData) {
                    tempAllHadiths.add(Data.fromJson(h));
                  }
                }
              }
            }
          }
          // 2. Check: Agar direct "data" key ke andar list hai
          else if (decoded is Map && decoded.containsKey("data")) {
            var dataList = decoded["data"];
            if (dataList is List) {
              for (var d in dataList) {
                tempAllHadiths.add(Data.fromJson(d));
              }
            }
          }
          // 3. Check: Agar file direct ek List hai
          else if (decoded is List) {
            for (var item in decoded) {
              tempAllHadiths.add(Data.fromJson(item));
            }
          }
        } else {
          print("⚠️ File missing: $slug.json");
        }
      }

      if (mounted) {
        setState(() {
          allHadithsList = tempAllHadiths;
          isLoading = false;
        });
      }
      print("✅ Total Data Loaded: ${allHadithsList.length}");
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- SEARCH FILTER ---
  void _runFilter(String query) {
    List<Data> results = [];
    if (query.isEmpty) {
      results = [];
    } else {
      results = allHadithsList.where((hadith) {
        final hNumber = hadith.hadithNumber.toString();
        final hUrdu = (hadith.hadithUrdu ?? "").toLowerCase();
        // Dono number aur text search support karega
        return hNumber.contains(query) || hUrdu.contains(query.toLowerCase());
      }).toList();
    }

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Search (${allHadithsList.length} Hadiths)",
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Hadith Number...",
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

          // Results
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _searchController.text.isEmpty
                ? const Center(child: Text("Start searching..."))
                : searchResults.isEmpty
                ? const Center(child: Text("No Hadith found"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];
                      return HadithCardWidget(hadith: hadith);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- CARD WIDGET ---
class HadithCardWidget extends StatelessWidget {
  final Data hadith;
  const HadithCardWidget({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            hadith.hadithNumber.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
        title: Text(
          hadith.hadithArabic ?? "",
          textAlign: TextAlign.right,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hadith.hadithUrdu ?? "",
          textAlign: TextAlign.right,
          maxLines: 1,
          style: const TextStyle(color: Colors.green, fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  hadith.hadithArabic ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(),
                Text(
                  hadith.hadithUrdu ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                ),
                if (hadith.hadithEnglish != null) ...[
                  const Gap(10),
                  Text(
                    hadith.hadithEnglish!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
