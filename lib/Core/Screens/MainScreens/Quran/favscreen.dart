import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Core/Services/rewarded_ad_services.dart';
import 'package:flutter/material.dart';
import 'package:muslim/Core/Screens/MainScreens/Quran/quran_surah.dart';
import 'package:muslim/Core/Widgets/Buttons/iconbutton.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FavouriteScreen extends StatefulWidget {
  final List<String> favouriteSurahNames;
  final List<int> favouriteSurahnumber;
  const FavouriteScreen(
    this.favouriteSurahNames, {
    super.key,
    required this.favouriteSurahnumber,
  });

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton0(
            onPressed: () {
              Navigator.pop(context);
              AdController().tryShowAd();
            },
            bicon: Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          ),
          backgroundColor: Colors.amber.shade100,
          automaticallyImplyLeading: false,
          title: Text(
            "Favourites",
            style: TextStyle(fontSize: height * 0.040, color: Colors.black54),
          ),
        ),
        backgroundColor: Colors.white,
        body: widget.favouriteSurahNames.isEmpty
            ? Center(child: Text("No Favouties"))
            : ListView.builder(
                itemCount: widget.favouriteSurahNames.length,
                itemBuilder: (context, index) {
                  final surahName = widget.favouriteSurahNames[index];
                  final surahnumber = widget.favouriteSurahnumber[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuranSurah(surahName),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      child: Card(
                        elevation: 5,

                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            surahName,
                            style: TextStyle(
                              fontSize: height * 0.035,
                              color: Colors.black87,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: height * 0.028,
                            child: Text(
                              surahnumber.toString(),
                              style: TextStyle(
                                fontSize: height * 0.027,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      onWillPop: () async {
        Navigator.pop(context);
        AdController().tryShowAd();
        return false;
      },
    );
  }
}
