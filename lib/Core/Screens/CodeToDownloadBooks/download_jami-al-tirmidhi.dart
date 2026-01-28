import 'dart:convert';
import 'dart:io';

import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadJamialtirmidhi {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> downloadjamiatirmidhi() async {
    try {
      final getResponse = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/al-tirmidhi/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );
      final responsedecode = jsonDecode(getResponse.body);
      final chapterlist = responsedecode["chapters"] ?? [];
      if (getResponse.statusCode == 200) {
        for (var hadiths in chapterlist) {
          final chapterNo = hadiths["chapterNumber"];
          final hadithresponse = await http.get(
            Uri.parse(
              "https://hadithapi.com/api/hadiths/?book=al-tirmidhi&chapter=$chapterNo&apiKey=$apiKey",
            ),
          );
          if (hadithresponse.statusCode == 200) {
            final hadithdecode = jsonDecode(hadithresponse.body);
            final hadithdetails = HadithDetails.fromJson(hadithdecode);
            hadiths["hadiths"] = hadithdetails.hadiths?.toJson();
          } else {
            throw Exception("failed to fetch hadits");
          }
        }
        //save all data to local
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/al-tirmidhi.json");
        await file.writeAsString(
          jsonEncode({"book": "al-tirmidhi", "chapters": chapterlist}),
        );
      }
    } catch (e) {
      throw Exception("error ${e.toString()}");
    }
  }
}
