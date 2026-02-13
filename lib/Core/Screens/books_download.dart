import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Screens/CodeToDownloadBooks/download_jami-al-tirmidhi.dart';
import '../Screens/CodeToDownloadBooks/download_sahi-muslim.dart';
import '../Screens/CodeToDownloadBooks/download_sahi-bukhari.dart';
import '../Screens/CodeToDownloadBooks/download_sunan_abu_dawood.dart';
import '../Screens/CodeToDownloadBooks/download_sunan_annasai.dart';
import '../Screens/CodeToDownloadBooks/download_sunan_ibn_majah.dart';

class DownloadService extends ChangeNotifier {
  /// 🔥 Singleton
  static final DownloadService instance = DownloadService._internal();
  DownloadService._internal();

  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _isDownloaded = {};

  /// 🔒 sirf aik book download hogi
  String? _currentDownloadingSlug;

  bool isDownloading(String slug) => _isDownloading[slug] == true;
  bool isDownloaded(String slug) => _isDownloaded[slug] == true;

  Future<void> checkDownloaded(String slug) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$slug.json");
    _isDownloaded[slug] = file.existsSync();
    notifyListeners();
  }

  Future<void> downloadBook(
    BuildContext context,
    String slug, {
    required bool isUrdu,
  }) async {
    if (_currentDownloadingSlug != null && _currentDownloadingSlug != slug) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu
                ? "پہلے والی کتاب ڈاؤن لوڈ ہو رہی ہے"
                : "Another book is already downloading",
          ),
        ),
      );
      return;
    }

    if (_isDownloading[slug] == true) return;

    _currentDownloadingSlug = slug;
    _isDownloading[slug] = true;
    notifyListeners();

    try {
      if (slug == "sahih-bukhari") {
        await DownloadSahiBukhar().downloadbook();
      } else if (slug == "sahih-muslim") {
        await DownloadSahimuslim().downloadsahimuslim();
      } else if (slug == "al-tirmidhi") {
        await DownloadJamialtirmidhi().downloadjamiatirmidhi();
      } else if (slug == "abu-dawood") {
        await DownloadSunanAbuDawood().getdownload();
      } else if (slug == "ibn-e-majah") {
        await DownloadSunanIbnMajah().getdownloadbook();
      } else if (slug == "sunan-nasai") {
        await DownloadSunanAnnasai().getDownload();
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$slug.json");
      _isDownloaded[slug] = file.existsSync();
    } finally {
      _isDownloading[slug] = false;
      _currentDownloadingSlug = null;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String slug) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$slug.json");

    if (file.existsSync()) {
      await file.delete();
      _isDownloaded[slug] = false;
      notifyListeners();
    }
  }
}
