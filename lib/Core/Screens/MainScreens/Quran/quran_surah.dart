// ignore_for_file: avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Core/Services/audios.dart';
import 'package:muslim/Core/Services/rewarded_ad_services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:muslim/Core/Const/apptextstyle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranSurah extends StatefulWidget {
  final String surahName;
  const QuranSurah(this.surahName, {super.key});

  @override
  State<QuranSurah> createState() => _QuranSurahState();
}

class _QuranSurahState extends State<QuranSurah> {
  String surahText = "";
  late ScrollController _scrollcontroller;
  bool ispaused = false;
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _positon = Duration.zero;

  Future<bool> hasinternet() async {
    try {
      // First check if device has a network
      var connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      if (connectivityResult == ConnectivityResult.none) {
        return false; // no network
      }
      // Actually check if we can reach a server
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // String? getAudioUrl(String surahName) {
  //   switch (surahName.toLowerCase()) {
  //     case "al-fatihah":
  //       return Audios.alFatiha;
  //     case "al-baqarah":
  //       return Audios.alBaqrah;
  //     case "aal-e-imran":
  //       return Audios.alImran;
  //     case "an-nisa":
  //       return Audios.anNisa;
  //     case "al-maidah":
  //       return Audios.alMaidah;
  //     case "al-anam":
  //       return Audios.alAnam;
  //     case "al-araf":
  //       return Audios.alAraf;
  //     case "al-anfal":
  //       return Audios.alAnfal;
  //     case "at-tawbah":
  //       return Audios.atTawbah;
  //     case "yunus":
  //       return Audios.younus;
  //     case "hud":
  //       return Audios.hud;
  //     case "yusuf":
  //       return Audios.yousaf;
  //     case "ar-rad":
  //       return Audios.arRad;
  //     case "ibrahim":
  //       return Audios.ibrahim;
  //     case "al-hijr":
  //       return Audios.alHijar;
  //     case "an-nahl":
  //       return Audios.anNahl;
  //     case "al-isra":
  //       return Audios.alisra;
  //     case "al-kahf":
  //       return Audios.alKahf;
  //     case "maryam":
  //       return Audios.maryam;
  //     case "ta-ha":
  //       return Audios.taha;
  //     case "al-anbiya":
  //       return Audios.alAnbya;
  //     case "al-hajj":
  //       return Audios.alHajj;
  //     case "al-muminun":
  //       return Audios.alMuminun;
  //     case "an-nur":
  //       return Audios.anNur;
  //     case "al-furqan":
  //       return Audios.alFurqan;
  //     case "ash-shuara":
  //       return Audios.ashShaura;
  //     case "an-naml":
  //       return Audios.anNaml;
  //     case "al-qasas":
  //       return Audios.alQasas;
  //     case "al-ankabut":
  //       return Audios.alAnkabout;
  //     case "ar-rum":
  //       return Audios.arRum;
  //     case "luqman":
  //       return Audios.luqman;
  //     case "as-sajda":
  //       return Audios.asSajda;
  //     case "al-ahzab":
  //       return Audios.alAhzab;
  //     case "saba":
  //       return Audios.saba;
  //     case "fatir":
  //       return Audios.fatir;
  //     case "yasin":
  //       return Audios.yasin;
  //     case "as-saffat":
  //       return Audios.asSaffat;
  //     case "sad":
  //       return Audios.sad;
  //     case "az-zumar":
  //       return Audios.azZumar;
  //     case "ghafir":
  //       return Audios.ghafir;
  //     case "fussilat":
  //       return Audios.fussilat;
  //     case "ash-shura":
  //       return Audios.asShaura;
  //     case "az-zukhruf":
  //       return Audios.azZakhruf;
  //     case "ad-dukhan":
  //       return Audios.adDukhan;
  //     case "al-jathiya":
  //       return Audios.alJathiya;
  //     case "al-ahqaf":
  //       return Audios.alAhqaf;
  //     case "muhammad":
  //       return Audios.Muhammad;
  //     case "al-fath":
  //       return Audios.alFath;
  //     case "al-hujraat":
  //       return Audios.alHujraat;
  //     case "qaaf":
  //       return Audios.qaaf;
  //     case "adh-dhariyat":
  //       return Audios.adhDharyaat;
  //     case "at-tur":
  //       return Audios.atTur;
  //     case "an-najm":
  //       return Audios.anNajam;
  //     case "al-qamar":
  //       return Audios.alQamar;
  //     case "ar-rahman":
  //       return Audios.arRahman;
  //     case "al-waqia":
  //       return Audios.alWaqia;
  //     case "al-hadid":
  //       return Audios.alHadid;
  //     case "al-mujadila":
  //       return Audios.alMujadila;
  //     case "al-hashr":
  //       return Audios.alHashr;
  //     case "al-mumtahina":
  //       return Audios.alMumtahina;
  //     case "as-saff":
  //       return Audios.anSaf;
  //     case "al-jumua":
  //       return Audios.alJumua;
  //     case "al-munafiqoon":
  //       return Audios.alMunafiqoon;
  //     case "at-taghabun":
  //       return Audios.atTaghabun;
  //     case "at-talaq":
  //       return Audios.atTalaq;
  //     case "at-tahrim":
  //       return Audios.alTahrim;
  //     case "al-mulk":
  //       return Audios.alMulk;
  //     case "al-qalam":
  //       return Audios.alQalam;
  //     case "al-haaqqa":
  //       return Audios.alHaaqqa;
  //     case "al-marij":
  //       return Audios.alMarij;
  //     case "nuh":
  //       return Audios.nuh;
  //     case "al-jin":
  //       return Audios.alJin;
  //     case "al-muzzammil":
  //       return Audios.alMuzzammil;
  //     case "al-muddathir":
  //       return Audios.alMuddathir;
  //     case "al-qiyama":
  //       return Audios.alQiyama;
  //     case "al-insan":
  //       return Audios.alInsan;
  //     case "al-mursalat":
  //       return Audios.alMursalat;
  //     case "an-naba":
  //       return Audios.anNaba;
  //     case "an-naziat":
  //       return Audios.anNaziat;
  //     case "abasa":
  //       return Audios.abasa;
  //     case "at-takwir":
  //       return Audios.atTakwir;
  //     case "al-infitar":
  //       return Audios.alInfitar;
  //     case "al-mutaffifin":
  //       return Audios.alMutaffifin;
  //     case "al-inshiqa":
  //       return Audios.alInshiqa;
  //     case "al-burooj":
  //       return Audios.alBurooj;
  //     case "at-tariq":
  //       return Audios.atTariq;
  //     case "al-ala":
  //       return Audios.alAla;
  //     case "al-ghashiya":
  //       return Audios.alGhashiya;
  //     case "al-fajar":
  //       return Audios.alFajar;
  //     case "al-balad":
  //       return Audios.alBalad;
  //     case "ash-shams":
  //       return Audios.ashShams;
  //     case "al-lail":
  //       return Audios.alLail;
  //     case "ad-dhuha":
  //       return Audios.adDhuha;
  //     case "ash-sharh":
  //       return Audios.ashSharh;
  //     case "at-tin":
  //       return Audios.atTin;
  //     case "al-alaq":
  //       return Audios.alAlaq;
  //     case "al-qadr":
  //       return Audios.alQadr;
  //     case "al-bayyina":
  //       return Audios.alBayyina;
  //     case "az-zalzala":
  //       return Audios.azZalzala;
  //     case "al-adiyat":
  //       return Audios.alAdiyat;
  //     case "al-qaria":
  //       return Audios.alQaria;
  //     case "at-takathur":
  //       return Audios.atTakathur;
  //     case "al-asr":
  //       return Audios.alAsr;
  //     case "al-humaza":
  //       return Audios.alHumaza;
  //     case "al-fil":
  //       return Audios.alFil;
  //     case "quraish":
  //       return Audios.quraish;
  //     case "al-maun":
  //       return Audios.alMaun;
  //     case "al-kawthar":
  //       return Audios.alKawthar;
  //     case "al-kafiroon":
  //       return Audios.alKafiroon;
  //     case "an-nasr":
  //       return Audios.anNasr;
  //     case "al-masad":
  //       return Audios.alMasad;
  //     case "al-ikhlas":
  //       return Audios.alIkhlas;
  //     case "al-falaq":
  //       return Audios.alFalaq;
  //     case "an-nas":
  //       return Audios.anNas;
  //     default:
  //       return null;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    RewardedAdServices.adLoading();
    _loadSurahText();
    _scrollcontroller = ScrollController();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    ispaused = true;

    // _player.onPlayerStateChanged.listen((state) {
    //   if (mounted) {
    //     setState(() {
    //       ispaused = (state != PlayerState.playing);
    //     });
    //   }
    // });

    // _player.onDurationChanged.listen((d) {
    //   if (mounted) {
    //     setState(() {
    //       _duration = d;
    //     });
    //   }
    // });

    // _player.onPositionChanged.listen((p) {
    //   if (mounted) {
    //     setState(() {
    //       _positon = p;
    //     });
    //   }
    // });

    // _player.onPlayerComplete.listen((event) {
    //   if (mounted) {
    //     setState(() {
    //       ispaused = true;
    //       _positon = Duration.zero;
    //     });
    //   }
    // });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      // Format as HH:MM:SS
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      // Format as MM:SS
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }

  @override
  void dispose() {
    try {
      _player.stop();
    } catch (_) {}
    // ✅ Wait briefly to let MediaPlayer finish callbacks before dispose
    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        _player.dispose();
      } catch (_) {}
    });
    super.dispose();
  }

  Future<void> _loadSurahText() async {
    try {
      String cleanName = widget.surahName
          .toLowerCase()
          .replaceAll(" ", "")
          .replaceAll("-", "");

      String path = "assets/Quran/$cleanName.text";
      String data = await rootBundle.loadString(path);

      if (!mounted) return;
      setState(() {
        surahText = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        surahText = "Surah text not available for ${widget.surahName}.";
      });
    }
  }

  Future<void> savelastscroll() async {
    final scrollsp = await SharedPreferences.getInstance();
    await scrollsp.setDouble(
      "offset${widget.surahName}",
      _scrollcontroller.offset,
    );
  }

  Future<void> getlastscroll() async {
    SharedPreferences lastsp = await SharedPreferences.getInstance();
    final offset = lastsp.getDouble("offset${widget.surahName}") ?? 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollcontroller.hasClients) {
        _scrollcontroller.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double widht = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        AdController().tryShowAd();
        try {
          await _player.stop(); // ✅ just stop, dispose handled later
        } catch (_) {}
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              AdController().tryShowAd();
              try {
                await _player.stop(); // ✅ only stop
              } catch (_) {}
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text(
            widget.surahName,
            style: Apptextstyle.title.copyWith(
              color: Colors.white,
              fontSize: widht * 0.055,
            ),
          ),
        ),
        backgroundColor: Color(0XFFddffff),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            controller: _scrollcontroller,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: Color(0xffADD8E6),

                    selectionHandleColor: Colors.green,
                  ),
                ),
                child: SelectableText(
                  surahText,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiriQuran(
                    fontSize: 30,
                    height: 2.2,
                    wordSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
