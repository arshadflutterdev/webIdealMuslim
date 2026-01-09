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

  // Future<void> downloadBook(BuildContext context, String slug) async {
  //   /// ❌ agar koi aur book already download ho rahi hai
  //   if (_currentDownloadingSlug != null && _currentDownloadingSlug != slug) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Another book is already downloading")),
  //     );
  //     return;
  //   }

  //   if (_isDownloading[slug] == true) return;

  //   _currentDownloadingSlug = slug;
  //   _isDownloading[slug] = true;
  //   notifyListeners();

  //   try {
  //     if (slug == "sahih-bukhari") {
  //       await DownloadSahiBukhar().downloadbook();
  //     } else if (slug == "sahih-muslim") {
  //       await DownloadSahimuslim().downloadsahimuslim();
  //     } else if (slug == "al-tirmidhi") {
  //       await DownloadJamialtirmidhi().downloadjamiatirmidhi();
  //     } else if (slug == "abu-dawood") {
  //       await DownloadSunanAbuDawood().getdownload();
  //     } else if (slug == "ibn-e-majah") {
  //       await DownloadSunanIbnMajah().getdownloadbook();
  //     } else if (slug == "sunan-nasai") {
  //       await DownloadSunanAnnasai().getDownload();
  //     }

  //     final dir = await getApplicationDocumentsDirectory();
  //     final file = File("${dir.path}/$slug.json");
  //     _isDownloaded[slug] = file.existsSync();
  //   } catch (e) {
  //     debugPrint("Download error: $e");
  //   } finally {
  //     _isDownloading[slug] = false;
  //     _currentDownloadingSlug = null;
  //     notifyListeners();
  //   }
  // }

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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// import '../Screens/CodeToDownloadBooks/download_jami-al-tirmidhi.dart';
// import '../Screens/CodeToDownloadBooks/download_sahi-muslim.dart';
// import '../Screens/CodeToDownloadBooks/download_sahi-bukhari.dart';
// import '../Screens/CodeToDownloadBooks/download_sunan_abu_dawood.dart';
// import '../Screens/CodeToDownloadBooks/download_sunan_annasai.dart';
// import '../Screens/CodeToDownloadBooks/download_sunan_ibn_majah.dart';

// class DownloadService extends ChangeNotifier {
//   /// 🔥 Singleton
//   static final DownloadService instance = DownloadService._internal();
//   DownloadService._internal();

//   final Map<String, bool> _isDownloading = {};
//   final Map<String, bool> _isDownloaded = {};

//   bool isDownloading(String slug) => _isDownloading[slug] == true;
//   bool isDownloaded(String slug) => _isDownloaded[slug] == true;

//   Future<void> checkDownloaded(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");
//     _isDownloaded[slug] = file.existsSync();
//     notifyListeners();
//   }

//   Future<void> downloadBook(String slug) async {
//     if (_isDownloading[slug] == true) return;

//     _isDownloading[slug] = true;
//     notifyListeners();

//     try {
//       if (slug == "sahih-bukhari") {
//         await DownloadSahiBukhar().downloadbook();
//       } else if (slug == "sahih-muslim") {
//         await DownloadSahimuslim().downloadsahimuslim();
//       } else if (slug == "al-tirmidhi") {
//         await DownloadJamialtirmidhi().downloadjamiatirmidhi();
//       } else if (slug == "abu-dawood") {
//         await DownloadSunanAbuDawood().getdownload();
//       } else if (slug == "ibn-e-majah") {
//         await DownloadSunanIbnMajah().getdownloadbook();
//       } else if (slug == "sunan-nasai") {
//         await DownloadSunanAnnasai().getDownload();
//       }

//       final dir = await getApplicationDocumentsDirectory();
//       final file = File("${dir.path}/$slug.json");
//       _isDownloaded[slug] = file.existsSync();
//     } catch (e) {
//       debugPrint("Download error: $e");
//     } finally {
//       _isDownloading[slug] = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteBook(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");

//     if (file.existsSync()) {
//       await file.delete();
//       _isDownloaded[slug] = false;
//       notifyListeners();
//     }
//   }
// }

// import 'dart:io';

// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_jami-al-tirmidhi.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-bukhari.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-muslim.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_abu_dawood.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_annasai.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_ibn_majah.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class DownloadService extends ChangeNotifier {
//   static final DownloadService instance = DownloadService._internal();
//   DownloadService._internal();

//   final Map<String, bool> _isDownloading = {};
//   final Map<String, bool> _isDownloaded = {};

//   bool isDownloading(String slug) => _isDownloading[slug] == true;
//   bool isDownloaded(String slug) => _isDownloaded[slug] == true;

//   Future<void> checkDownloaded(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");
//     _isDownloaded[slug] = file.existsSync();
//     notifyListeners();
//   }

//   /// Start download **independently** (parallel)
//   Future<void> downloadBook(String slug) async {
//     if (_isDownloading[slug] == true) return; // already downloading

//     _isDownloading[slug] = true;
//     notifyListeners();

//     try {
//       if (slug == "sahih-bukhari") {
//         await DownloadSahiBukhar().downloadbook();
//       } else if (slug == "sahih-muslim") {
//         await DownloadSahimuslim().downloadsahimuslim();
//       } else if (slug == "al-tirmidhi") {
//         await DownloadJamialtirmidhi().downloadjamiatirmidhi();
//       } else if (slug == "abu-dawood") {
//         await DownloadSunanAbuDawood().getdownload();
//       } else if (slug == "ibn-e-majah") {
//         await DownloadSunanIbnMajah().getdownloadbook();
//       } else if (slug == "sunan-nasai") {
//         await DownloadSunanAnnasai().getDownload();
//       }

//       final dir = await getApplicationDocumentsDirectory();
//       final file = File("${dir.path}/$slug.json");
//       _isDownloaded[slug] = file.existsSync();
//     } catch (e) {
//       debugPrint("Download error: $e");
//     } finally {
//       _isDownloading[slug] = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteBook(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");

//     if (file.existsSync()) {
//       await file.delete();
//       _isDownloaded[slug] = false;
//       notifyListeners();
//     }
//   }
// }

// import 'dart:io';

// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_jami-al-tirmidhi.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-bukhari.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sahi-muslim.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_abu_dawood.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_annasai.dart';
// import 'package:Muslim/Core/Screens/CodeToDownloadBooks/download_sunan_ibn_majah.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class DownloadService extends ChangeNotifier {
//   /// Singleton instance
//   static final DownloadService instance = DownloadService._internal();
//   DownloadService._internal();

//   final Map<String, bool> _isDownloading = {};
//   final Map<String, bool> _isDownloaded = {};

//   final List<_DownloadTask> _queue = [];
//   bool _isProcessingQueue = false;

//   /// Check if a slug is currently downloading
//   bool isDownloading(String slug) => _isDownloading[slug] == true;

//   /// Check if a slug is already downloaded
//   bool isDownloaded(String slug) => _isDownloaded[slug] == true;

//   /// Check local file to update downloaded state
//   Future<void> checkDownloaded(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");
//     _isDownloaded[slug] = file.existsSync();
//     notifyListeners();
//   }

//   /// Queue a download task
//   void downloadBook(String slug) {
//     // Avoid adding duplicate tasks
//     if (_queue.any((task) => task.slug == slug)) return;

//     _queue.add(_DownloadTask(slug: slug));
//     _processQueue();
//   }

//   /// Process the download queue (only one at a time)
//   void _processQueue() async {
//     if (_isProcessingQueue || _queue.isEmpty) return;

//     _isProcessingQueue = true;

//     while (_queue.isNotEmpty) {
//       final task = _queue.removeAt(0);
//       final slug = task.slug;

//       if (isDownloading(slug)) continue;

//       _isDownloading[slug] = true;
//       notifyListeners();

//       try {
//         // Call the correct download function for each book
//         if (slug == "sahih-bukhari") {
//           await DownloadSahiBukhar().downloadbook();
//         } else if (slug == "sahih-muslim") {
//           await DownloadSahimuslim().downloadsahimuslim();
//         } else if (slug == "al-tirmidhi") {
//           await DownloadJamialtirmidhi().downloadjamiatirmidhi();
//         } else if (slug == "abu-dawood") {
//           await DownloadSunanAbuDawood().getdownload();
//         } else if (slug == "ibn-e-majah") {
//           await DownloadSunanIbnMajah().getdownloadbook();
//         } else if (slug == "sunan-nasai") {
//           await DownloadSunanAnnasai().getDownload();
//         }

//         // Check if file exists locally
//         final dir = await getApplicationDocumentsDirectory();
//         final file = File("${dir.path}/$slug.json");
//         _isDownloaded[slug] = file.existsSync();
//       } catch (e) {
//         debugPrint("Download error for $slug: $e");
//       } finally {
//         _isDownloading[slug] = false;
//         notifyListeners();
//       }
//     }

//     _isProcessingQueue = false;
//   }

//   /// Delete a downloaded book
//   Future<void> deleteBook(String slug) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File("${dir.path}/$slug.json");

//     if (file.existsSync()) {
//       await file.delete();
//       _isDownloaded[slug] = false;
//       notifyListeners();
//     }
//   }
// }

// class _DownloadTask {
//   final String slug;
//   _DownloadTask({required this.slug});
// }
