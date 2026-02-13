import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
// Apne model ka path confirm kar lein
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadeesWeb extends StatefulWidget {
  const SearchAhadeesWeb({super.key});

  @override
  State<SearchAhadeesWeb> createState() => _SearchAhadeesWebState();
}

class _SearchAhadeesWebState extends State<SearchAhadeesWeb> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> searchResults = [];
  bool isLoading = false;

  // API Config
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  // List of books to search within
  final List<String> bookSlugs = [
    "sahih-bukhari",
    "sahih-muslim",
    "al-tirmidhi",
    "abu-dawood",
    "sunan-nasai",
    "sunan-ibn-majah",
  ];

  // --- Search Function ---
  Future<void> _searchHadith(String number) async {
    if (number.isEmpty) return;

    setState(() {
      isLoading = true;
      searchResults = []; // Purane results clear
    });

    try {
      List<Data> tempResults = [];

      // Parallel Requests: Saari books ko ek sath hit karein
      await Future.wait(
        bookSlugs.map((slug) async {
          final url =
              "https://hadithapi.com/api/hadiths?apiKey=$apiKey&hadithNumber=$number&book=$slug";

          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final decoded = jsonDecode(response.body);
              // Search API ka structure: hadiths -> data
              if (decoded['hadiths'] != null &&
                  decoded['hadiths']['data'] != null) {
                final List data = decoded['hadiths']['data'];
                for (var item in data) {
                  tempResults.add(Data.fromJson(item));
                }
              }
            }
          } catch (e) {
            debugPrint("Error fetching $slug: $e");
          }
        }),
      );

      setState(() {
        searchResults = tempResults;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Global Search Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Global Hadith Search",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (val) => _searchHadith(val),
                    decoration: InputDecoration(
                      hintText: "Enter Hadith Number (e.g., 1, 42, 105)",
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  onPressed: () => _searchHadith(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Result Section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : searchResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildHadithCard(searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.find_in_page_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const Gap(10),
          Text(
            _searchController.text.isEmpty
                ? "Search hadith across all major books"
                : "No results found for this number",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(Data hadith) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            hadith.hadithNumber ?? "?",
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          hadith.book?.bookName ?? "Hadith",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        subtitle: Text(
          hadith.hadithArabic ?? "",
          maxLines: 1,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Arabic', fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                Text(
                  hadith.hadithArabic ?? "",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.6,
                    fontFamily: 'Arabic',
                  ),
                ),
                const Gap(15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hadith.hadithUrdu ?? "",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ),
                const Gap(15),
                Text(
                  hadith.hadithEnglish ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
