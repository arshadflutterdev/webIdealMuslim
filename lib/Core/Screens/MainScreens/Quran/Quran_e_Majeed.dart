import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:muslim/Core/Screens/MainScreens/Quran/favscreen.dart';
import 'package:muslim/Core/Screens/MainScreens/Quran/quran_surah.dart';
import 'package:muslim/Core/Widgets/Buttons/iconbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class QuranEMajeed extends StatefulWidget {
  const QuranEMajeed({super.key});

  @override
  State<QuranEMajeed> createState() => _QuranEMajeedState();
}

class _QuranEMajeedState extends State<QuranEMajeed> {
  final List<String> surahNames = [
    'Al-Fatihah',
    'Al-Baqarah',
    'Aal-E-Imran',
    'An-Nisa',
    'Al-Maidah',
    'Al-Anam',
    'Al-Araf',
    'Al-Anfal',
    'At-Tawbah',
    'Yunus',
    'Hud',
    'Yusuf',
    'Ar-Rad',
    'Ibrahim',
    'Al-Hijr',
    'An-Nahl',
    'Al-Isra',
    'Al-Kahf',
    'Maryam',
    'Ta-Ha',
    'Al-Anbiya',
    'Al-Hajj',
    'Al-Muminun',
    'An-Nur',
    'Al-Furqan',
    'Ash-Shuara',
    'An-Naml',
    'Al-Qasas',
    'Al-Ankabut',
    'Ar-Rum',
    'Luqman',
    'As-Sajda',
    'Al-Ahzab',
    'Saba',
    'Fatir',
    'Ya-Sin',
    'As-Saffat',
    'Sad',
    'Az-Zumar',
    'Ghafir',
    'Fussilat',
    'Ash-Shura',
    'Az-Zukhruf',
    'Ad-Dukhan',
    'Al-Jathiya',
    'Al-Ahqaf',
    'Muhammad',
    'Al-Fath',
    'Al-Hujraat',
    'Qaf',
    'Adh-Dhariyat',
    'At-Tur',
    'An-Najm',
    'Al-Qamar',
    'Ar-Rahman',
    'Al-Waqia',
    'Al-Hadid',
    'Al-Mujadila',
    'Al-Hashr',
    'Al-Mumtahina',
    'As-Saff',
    'Al-Jumua',
    'Al-Munafiqoon',
    'At-Taghabun',
    'At-Talaq',
    'At-Tahrim',
    'Al-Mulk',
    'Al-Qalam',
    'Al-Haaqqa',
    'Al-Maarij',
    'Nuh',
    'Al-Jinn',
    'Al-Muzzammil',
    'Al-Muddathir',
    'Al-Qiyama',
    'Al-Insan',
    'Al-Mursalat',
    'An-Naba',
    'An-Nazi’at',
    'Abasa',
    'At-Takwir',
    'Al-Infitar',
    'Al-Mutaffifin',
    "Al-Inshiqa",
    'Al-Burooj',
    'At-Tariq',
    'Al-Ala',
    'Al-Ghashiya',
    'Al-Fajr',
    'Al-Balad',
    'Ash-Shams',
    'Al-Lail',
    'Ad-Dhuha',
    'Ash-Sharh',
    'At-Tin',
    'Al-Alaq',
    'Al-Qadr',
    'Al-Bayyina',
    'Az-Zalzala',
    'Al-Adiyat',
    'Al-Qaria',
    'At-Takathur',
    'Al-Asr',
    'Al-Humaza',
    'Al-Fil',
    'Quraish',
    'Al-Maun',
    'Al-Kawthar',
    'Al-Kafiroon',
    'An-Nasr',
    'Al-Masad',
    'Al-Ikhlas',
    'Al-Falaq',
    'An-Nas',
  ];

  late List<bool> favourites;
  late List<String> searchSurrah;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    favourites = List<bool>.filled(surahNames.length, false);
    searchSurrah = List.from(surahNames);
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('quran_favourites');
    if (saved != null && saved.length == surahNames.length) {
      favourites = saved.map((e) => e == 'true').toList();
    }
    setState(() {});
  }

  Future<void> _saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final asStrings = favourites.map((e) => e.toString()).toList();
    await prefs.setStringList('quran_favourites', asStrings);
  }

  void _filterSurahs(String query) {
    setState(() {
      searchSurrah = query.isEmpty
          ? List.from(surahNames)
          : surahNames
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                .toList();
    });
  }

  Future<bool> _onWillPop() async {
    if (searchSurrah.length != surahNames.length) {
      setState(() {
        searchSurrah = List.from(surahNames);
        _controller.clear();
      });
      return false;
    }
    return false;
  }

  final _url = Uri.parse("https://aifiesta.link/shikh");
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    bool isMobile = width < 600;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF8F6),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFFCF8F6),
          centerTitle: true,
          title: Row(
            children: [
              Gap(10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (!await launchUrl(_url)) {
                    throw Exception('Could not launch $_url');
                  }
                },
                child: Text(
                  "Ai Fiesta",
                  style: isMobile
                      ? TextStyle(color: Colors.white, fontSize: 15)
                      : TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),

              Spacer(),
              Text(
                "Al-Qur’an",
                style: kIsWeb
                    ? TextStyle(
                        fontSize: isMobile ? height * 0.020 : height * 0.070,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F3E34),
                      )
                    : TextStyle(
                        fontSize: height * 0.040,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F3E34),
                      ),
              ),
              Gap(10),
              Spacer(),
            ],
          ),
          actions: [
            // IconButton0(
            //   onPressed: () {
            //     showDialog(
            //       context: context,
            //       builder: (_) => AlertDialog(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         title: const Text("Search Surah"),
            //         content: TextField(
            //           controller: _controller,
            //           onChanged: _filterSurahs,
            //           decoration: const InputDecoration(
            //             hintText: "Type surah name",
            //           ),
            //         ),
            //         actions: [
            //           CustomTextButton(
            //             onPressed: () {
            //               _filterSurahs(_controller.text);
            //               _controller.clear();
            //               Navigator.pop(context);
            //             },
            //             bchild: const Text(
            //               "Search",
            //               style: TextStyle(color: Colors.green),
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            //   bicon: Icon(
            //     CupertinoIcons.search,
            //     size: height * 0.050,
            //     color: Colors.black54,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red, size: 40),
                onPressed: () {
                  final favNames = <String>[];
                  final favNums = <int>[];
                  for (int i = 0; i < surahNames.length; i++) {
                    if (favourites[i]) {
                      favNames.add(surahNames[i]);
                      favNums.add(i + 1);
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavouriteScreen(
                        favNames,
                        favouriteSurahnumber: favNums,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        body: kIsWeb
            ? Padding(
                padding: EdgeInsets.only(
                  top: isMobile ? height * 0.030 : height * 0.080,
                ),
                child: GridView.builder(
                  itemCount: searchSurrah.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    childAspectRatio: isMobile ? 5 : 5,
                  ),
                  itemBuilder: (context, index) {
                    final actualIndex = surahNames.indexOf(searchSurrah[index]);
                    final surahNumber = actualIndex + 1;
                    final isFavourite = favourites[actualIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Container(
                        height: height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: InkWell(
                          canRequestFocus: false,
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Future.microtask(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      QuranSurah(searchSurrah[index]),
                                ),
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: height * 0.026,
                                  backgroundColor: const Color(0xFFDDEBDF),
                                  child: Text(
                                    surahNumber.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2F3E34),
                                      fontSize: height * 0.028,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    searchSurrah[index],
                                    style: TextStyle(
                                      fontSize: height * 0.038,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF2F3E34),
                                    ),
                                  ),
                                ),
                                IconButton0(
                                  onPressed: () {
                                    setState(() {
                                      favourites[actualIndex] =
                                          !favourites[actualIndex];
                                    });
                                    _saveFavourites();
                                  },
                                  bicon: Icon(
                                    isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavourite
                                        ? const Color(0xFFE85C5C)
                                        : const Color(0xFF9E9E9E),
                                    size: height * 0.045,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : ListView.builder(
                itemCount: searchSurrah.length,
                itemBuilder: (context, index) {
                  final actualIndex = surahNames.indexOf(searchSurrah[index]);
                  final surahNumber = actualIndex + 1;
                  final isFavourite = favourites[actualIndex];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Container(
                      height: height * 0.095,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuranSurah(searchSurrah[index]),
                              ),
                            );
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: height * 0.026,
                                backgroundColor: const Color(0xFFDDEBDF),
                                child: Text(
                                  surahNumber.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2F3E34),
                                    fontSize: height * 0.018,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  searchSurrah[index],
                                  style: TextStyle(
                                    fontSize: height * 0.028,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2F3E34),
                                  ),
                                ),
                              ),
                              IconButton0(
                                onPressed: () {
                                  setState(() {
                                    favourites[actualIndex] =
                                        !favourites[actualIndex];
                                  });
                                  _saveFavourites();
                                },
                                bicon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavourite
                                      ? const Color(0xFFE85C5C)
                                      : const Color(0xFF9E9E9E),
                                  size: height * 0.045,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
