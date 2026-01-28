import 'dart:convert';
import 'dart:io';

import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadSunanIbnMajah {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> getdownloadbook() async {
    try {
      final getresponse = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/ibn-e-majah/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );
      if (getresponse.statusCode != 200) {
        throw Exception("Apis failed to fetch data");
      }
      final responsedecode = jsonDecode(getresponse.body);
      final chapterlist = responsedecode["chapters"] ?? [];
      for (var chapter in chapterlist) {
        final chapterNo = chapter["chapterNumber"];
        final hadithResponse = await http.get(
          Uri.parse(
            "https://hadithapi.com/api/hadiths/?book=ibn-e-majah&chapter=$chapterNo&apiKey=$apiKey",
          ),
        );
        if (hadithResponse.statusCode == 200) {
          final hadithDecode = jsonDecode(hadithResponse.body);
          final hadithdetails = HadithDetails.fromJson(hadithDecode);
          chapter["hadiths"] = hadithdetails.hadiths?.toJson();
        }
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/ibn-e-majah.json");
      await file.writeAsString(
        jsonEncode({"book": "ibn-e-majah", "chapters": chapterlist}),
      );
    } catch (e) {
      throw Exception("Exception ${e.toString()}");
    }
  }
}
