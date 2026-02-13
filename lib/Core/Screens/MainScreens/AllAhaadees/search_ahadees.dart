import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye
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

  // Web APIs List
  final List<String> webUrls = [
    "https://hadith-proxy-mpc6.vercel.app/bukhari-hadiths",
    "https://hadith-proxy-mpc6.vercel.app/muslim-hadiths",
    "https://hadith-proxy-mpc6.vercel.app/tirmidhi-hadiths",
    "https://hadith-proxy-mpc6.vercel.app/abudowood-hadiths",
  ];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  // Main Loader (Mobile vs Web)
  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    if (kIsWeb) {
      await loadFromWeb();
    } else {
      await loadFromMobileStorage();
    }
    setState(() => isLoading = false);
  }

  // MOBILE: Load from Local JSON
  Future<void> loadFromMobileStorage() async {
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
      for (String name in fileNames) {
        final file = File("${dir.path}/$name");
        if (await file.exists()) {
          final content = await file.readAsString();
          parseAndAddData(content);
        }
      }
    } catch (e) {
      print("Mobile Loading Error: $e");
    }
  }

  // WEB: Load from APIs
  Future<void> loadFromWeb() async {
    try {
      // Parallel loading for speed on web
      final responses = await Future.wait(
        webUrls.map((url) => http.get(Uri.parse(url))),
      );
      for (var response in responses) {
        if (response.statusCode == 200) {
          parseAndAddData(response.body);
        }
      }
    } catch (e) {
      print("Web Loading Error: $e");
    }
  }

  // Helper to parse JSON (Works for both)
  void parseAndAddData(String jsonString) {
    final decoded = jsonDecode(jsonString);
    // Agar data API se aa raha hai toh 'hadiths' key check karein, agar local file hai toh 'chapters'
    if (decoded['hadiths'] != null) {
      final List data = decoded['hadiths']['data'] ?? [];
      allHadithsList.addAll(data.map((h) => Data.fromJson(h)).toList());
    } else if (decoded['chapters'] != null) {
      for (var chapter in decoded['chapters']) {
        final List data = chapter['hadiths']?['data'] ?? [];
        allHadithsList.addAll(data.map((h) => Data.fromJson(h)).toList());
      }
    }
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() => searchResults = []);
    } else {
      setState(() {
        searchResults = allHadithsList
            .where((h) => h.hadithNumber.toString().contains(enteredKeyword))
            .toList();
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
        title: Text(
          kIsWeb ? "Search Hadiths (Web)" : "Search Hadiths (Offline)",
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _searchController.text.isEmpty
                ? const Center(child: Text("You didn't search yet"))
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

  Widget buildHadithCard(Data hadith) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
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
              hadith.hadithUrdu ?? "",
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
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  hadith.hadithArabic ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 22, height: 1.6),
                ),
                const Gap(10),
                const Divider(),
                const Gap(10),
                Text(
                  hadith.hadithUrdu ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                ),
                const Gap(15),
                Text(
                  hadith.hadithEnglish ?? "",
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
