import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// Apne model ka path confirm kar lein
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

  // Aapki Proxy aur API Details
  final String proxyUrl = "https://cors-anywhere.herokuapp.com/";
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      loadAllBooksData();
    }
  }

  // --- WEB SEARCH LOGIC (Optimized for Search API Structure) ---
  Future<void> searchOnWeb(String number) async {
    setState(() {
      isLoading = true;
      searchResults = []; // Purani search clear karein
    });

    // Mashhoor kutub ki list
    List<String> books = [
      "sahih-bukhari",
      "sahih-muslim",
      "al-tirmidhi",
      "abu-dawood",
      "ibn-e-majah",
      "sunan-nasai",
    ];

    try {
      List<Data> tempResults = [];

      // Parallel requests bhej rahe hain taake search fast ho
      await Future.wait(
        books.map((bookSlug) async {
          final String apiUrl =
              "https://hadithapi.com/api/hadiths?apiKey=$apiKey&hadithNumber=$number&book=$bookSlug";

          // Web par proxyUrl ke sath, mobile par direct
          final finalUrl = kIsWeb ? proxyUrl + apiUrl : apiUrl;

          final response = await http.get(Uri.parse(finalUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> decoded = jsonDecode(response.body);

            // FIX: Search API mein "hadiths" key ke andar "data" list hoti hai
            if (decoded.containsKey('hadiths') &&
                decoded['hadiths']['data'] != null) {
              List<dynamic> dataList = decoded['hadiths']['data'];
              for (var item in dataList) {
                tempResults.add(Data.fromJson(item));
              }
            }
          }
        }),
      );

      setState(() {
        searchResults = tempResults;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Web Search Error: $e");
      setState(() => isLoading = false);
    }
  }

  // --- LOCAL DATA LOGIC (For Mobile Offline) ---
  Future<void> loadAllBooksData() async {
    setState(() => isLoading = true);
    // ... (Aapka local file loading logic yahan sahi kaam karega)
    setState(() => isLoading = false);
  }

  void _handleSearch(String value) {
    if (value.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    if (kIsWeb) {
      searchOnWeb(value.trim());
    } else {
      // Mobile filter logic
      final results = allHadithsList
          .where((h) => h.hadithNumber.toString() == value.trim())
          .toList();
      setState(() => searchResults = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Search All Hadiths",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted:
                  _handleSearch, // Keyboard ka "Search" button dabane par search ho
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Hadith Number and press Enter",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSearch(_searchController.text),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Result List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text("No Results Found"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];
                      return HadithCard(hadith: hadith);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// UI Card for Hadith Display
class HadithCard extends StatelessWidget {
  final Data hadith;
  const HadithCard({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            hadith.hadithNumber ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(
          hadith.hadithArabic ?? "",
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          hadith.book?.bookName ?? "Hadith Book",
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                Text(
                  hadith.hadithArabic ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 22, height: 1.5),
                ),
                const Gap(15),
                Text(
                  hadith.hadithUrdu ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    height: 1.5,
                  ),
                ),
                const Gap(15),
                Text(
                  hadith.hadithEnglish ?? "",
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
