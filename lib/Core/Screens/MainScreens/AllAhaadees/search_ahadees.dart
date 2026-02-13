import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> searchResults = [];
  bool isLoading = false;

  // PROXY: Agar aap apna proxy use kar rahe hain to yahan change karein
  final String proxyUrl = "https://cors-anywhere.herokuapp.com/";
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  // Books list for searching
  final List<String> books = [
    "sahih-bukhari",
    "sahih-muslim",
    "al-tirmidhi",
    "abu-dawood",
    "sunan-ibn-majah",
    "sunan-nasai",
  ];

  Future<void> searchHadithWeb(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      searchResults = [];
    });

    try {
      List<Data> tempResults = [];

      // Loop through books to find the specific hadith number
      for (String book in books) {
        String apiUrl =
            "https://hadithapi.com/api/hadiths?apiKey=$apiKey&hadithNumber=$query&book=$book";

        // Web context mein proxy lazmi hai
        String finalUrl = kIsWeb ? proxyUrl + apiUrl : apiUrl;

        print("Fetching from: $book..."); // Debugging

        final response = await http.get(Uri.parse(finalUrl));

        if (response.statusCode == 200) {
          final Map<String, dynamic> decoded = jsonDecode(response.body);

          // Hadith API ka search structure: decoded['hadiths']['data']
          if (decoded['hadiths'] != null &&
              decoded['hadiths']['data'] != null) {
            List<dynamic> data = decoded['hadiths']['data'];

            for (var item in data) {
              tempResults.add(Data.fromJson(item));
            }
          }
        } else {
          print("Error in $book: ${response.statusCode}");
        }
      }

      setState(() {
        searchResults = tempResults;
        isLoading = false;
      });

      print("Total Found: ${searchResults.length}");
    } catch (e) {
      print("Fatal Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search All Hadiths"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Hadith Number (e.g. 1)",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchHadithWeb(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (val) => searchHadithWeb(val),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                ? const Center(child: Text("No Data Found. Try searching '1'"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final hadith = searchResults[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Book: ${hadith.book?.bookName ?? 'N/A'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Divider(),
                              Text(
                                hadith.hadithArabic ?? "",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Arabic',
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                hadith.hadithUrdu ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
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
