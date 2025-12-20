import 'dart:convert';
import 'dart:io';

import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadSahiBukhar {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> downloadbook() async {
    try {
      final chapteresponse = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/sahih-bukhari/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );
      if (chapteresponse.statusCode != 200) {
        throw Exception("Failed to fetch Chapters");
      }
      final chapterJson = jsonDecode(chapteresponse.body);
      final chapterlist = chapterJson["chapters"] ?? [];

      //fetch hadith for all chapters
      for (var hadith in chapterlist) {
        final chapterNo = hadith["chapterNumber"];
        final hadithresponse = await http.get(
          Uri.parse(
            "https://hadithapi.com/api/hadiths/?book=sahih-bukhari&chapter=$chapterNo&apiKey=$apiKey",
          ),
        );
        if (hadithresponse.statusCode == 200) {
          final hadithdata = jsonDecode(hadithresponse.body);
          final hadithdetails = HadithDetails.fromJson(hadithdata);
          hadith["hadiths"] = hadithdetails.hadiths?.toJson();
        } else {
          print("failed to fetch all hadith data");
        }
      }
      //save all files to locally
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-bukhari.json");

      await file.writeAsString(
        jsonEncode({"book": "sahih-bukhari", "chapters": chapterlist}),
      );
    } catch (e) {
      print("error ${e.toString()}");
    }
  }
}
