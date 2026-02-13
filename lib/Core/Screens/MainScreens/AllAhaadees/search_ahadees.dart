import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye zaroori hai
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// Apne model ka path check kar lein
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

  // API Key (Same as provided)
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  @override
  void initState() {
    super.initState();
    // Agar mobile hai to local data load karein, web par direct search use hogi
    if (!kIsWeb) {
      loadAllBooksData();
    }
  }

  // --- MOBILE LOGIC: Local JSON Load ---
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
    } catch (e) {
      debugPrint("Error Loading Local Data: $e");
      setState(() => isLoading = false);
    }
  }

  // --- WEB LOGIC: Direct API Search ---
  Future<void> searchOnWeb(String number) async {
    List<String> books = [
      "sahih-bukhari",
      "sahih-muslim",
      "al-tirmidhi",
      "abu-dawood",
      "sunan-nasai",
      "sunan-ibn-majah",
    ];
    List<Data> webResults = [];

    try {
      // Multiple books mein parallel search
      await Future.wait(
        books.map((book) async {
          final url =
              "https://hadithapi.com/api/hadiths/?book=$book&hadithNumber=$number&apiKey=$apiKey";
          final res = await http.get(Uri.parse(url));

          if (res.statusCode == 200) {
            final decoded = jsonDecode(res.body);
            if (decoded["hadiths"] != null &&
                decoded["hadiths"]["data"] != null) {
              final List fetchedData = decoded["hadiths"]["data"];
              for (var item in fetchedData) {
                webResults.add(Data.fromJson(item));
              }
            }
          }
        }),
      );

      setState(() {
        searchResults = webResults;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Web Search Error: $e");
      setState(() => isLoading = false);
    }
  }

  // --- MAIN FILTER LOGIC ---
  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    if (kIsWeb) {
      // Web par API call karein
      setState(() => isLoading = true);
      searchOnWeb(enteredKeyword.trim());
    } else {
      // Mobile par local list se filter karein
      final results = allHadithsList.where((hadith) {
        return hadith.hadithNumber.toString() == enteredKeyword.trim();
      }).toList();

      setState(() {
        searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(kIsWeb ? "Web Search All Hadiths" : "Search All Hadiths"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Input
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
                ? const Center(child: Text("Type a number to search"))
                : searchResults.isEmpty
                ? const Center(child: Text("No Hadith Found"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];
                      return buildHadithCard(hadith);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Reusable Hadith Card Widget
  Widget buildHadithCard(Data hadith) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        shape: const Border(),
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
        title: Text(
          hadith.hadithArabic ?? "",
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arabic',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hadith.hadithUrdu ?? "Urdu translation not available",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Colors.green),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hadith.hadithEnglish ?? "",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(15),
        children: [
          const Divider(),
          Text(
            hadith.hadithArabic ?? "",
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 22, height: 1.6),
          ),
          const Gap(15),
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
              style: const TextStyle(fontSize: 17),
            ),
          ),
          const Gap(15),
          Text(
            hadith.hadithEnglish ?? "",
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
