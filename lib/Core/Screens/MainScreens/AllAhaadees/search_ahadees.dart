import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadithDetails.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/SahiBukhari/hadith_details_model.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  // 1. Controllers aur Lists
  final TextEditingController _searchController = TextEditingController();
  List<Data> haditsss = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getdownloadhadith(); // Page load hote hi data load kar lein
  }

  Future<void> getdownloadhadith() async {
    setState(() => isLoading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-bukhari.json");

      if (!file.existsSync()) {
        setState(() => isLoading = false);
        return;
      }

      final fileContent = await file.readAsString();
      final filedecode = jsonDecode(fileContent);
      final chapters = filedecode["chapters"];
      List<Data> allHadiths = [];

      if (chapters != null && chapters is List) {
        for (var chapter in chapters) {
          final hadithMap = chapter["hadiths"];
          if (hadithMap is Map<String, dynamic>) {
            final hadithList = hadithMap["data"];
            if (hadithList is List) {
              for (var h in hadithList) {
                allHadiths.add(Data.fromJson(h));
              }
            }
          }
        }
      }

      setState(() {
        haditsss = allHadiths;
        isLoading = false;
      });
      print("Total Hadiths Loaded for Search: ${haditsss.length}");
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Search Function
  void performSearch() {
    String searchNum = _searchController.text.trim();
    if (searchNum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a hadith number")),
      );
      return;
    }

    // List mein search karein
    final index = haditsss.indexWhere(
      (h) => h.hadithNumber.toString() == searchNum,
    );

    if (index != -1) {
      // Agar mil jaye toh Detail screen par bhej dein
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Hadithdetails(
            hadithNumber: searchNum,
            // ChapterId agar chahiye ho toh yahan se bhej sakte hain: haditsss[index].chapterId
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hadith not found!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                const Gap(20),
                const Text(
                  "Search Hadith",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController, // Controller lagaya
                    keyboardType: TextInputType.number, // Sirf numbers ke liye
                    decoration: InputDecoration(
                      hintText: "Enter Hadith Number (e.g. 15)",
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: performSearch, // Search function call kiya
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
    );
  }
}
