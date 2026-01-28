import 'dart:convert';
import 'dart:io';

import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadSunanAbuDawood {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> getdownload() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://hadithapi.com/api/abu-dawood/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte',
        ),
      );
      final responsedecode = jsonDecode(response.body);
      final chapterlist = responsedecode["chapters"] ?? [];
      if (response.statusCode == 200) {
        for (var hadiths in chapterlist) {
          final chapterno = hadiths["chapterNumber"];
          final hadithresponse = await http.get(
            Uri.parse(
              "https://hadithapi.com/api/hadiths/?book=abu-dawood&chapter=$chapterno&apiKey=$apiKey",
            ),
          );
          if (hadithresponse.statusCode == 200) {
            final hadithdecode = jsonDecode(hadithresponse.body);
            final hadithDetails = HadithDetails.fromJson(hadithdecode);
            // hadiths["hadiths"] = hadithDetails.hadiths?.toJson();
            hadiths["hadiths"] = {
              "data": hadithDetails.hadiths?.data
                  ?.map((h) => h.toJson())
                  .toList(),
            };
          } else {
            throw Exception("failed to fetch details");
          }
        }
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/abu-dawood.json");
      await file.writeAsString(
        jsonEncode({"book": "abu-dawood", "chapters": chapterlist}),
      );
    } catch (e) {
      throw Exception("here is error ${e.toString()}");
    }
  }
}
