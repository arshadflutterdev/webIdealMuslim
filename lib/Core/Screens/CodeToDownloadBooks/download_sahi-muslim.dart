import 'dart:convert';
import 'dart:io';

import 'package:muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadSahimuslim {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> downloadsahimuslim() async {
    try {
      final muslimresponse = await http.get(
        Uri.parse(
          "https://hadithapi.com/api/sahih-muslim/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
        ),
      );
      final chapterjson = jsonDecode(muslimresponse.body);
      final chapterlist = chapterjson["chapters"] ?? [];
      if (muslimresponse.statusCode == 200) {
        for (var hadiths in chapterlist) {
          final chaptersNo = hadiths["chapterNumber"];
          final hadithresponse = await http.get(
            Uri.parse(
              "https://hadithapi.com/api/hadiths/?book=sahih-muslim&chapter=$chaptersNo&apiKey=$apiKey",
            ),
          );
          if (hadithresponse.statusCode == 200) {
            final hadithdata = jsonDecode(hadithresponse.body);
            final hadithDetails = HadithDetails.fromJson(hadithdata);

            hadiths["hadiths"] = hadithDetails.hadiths?.toJson();
          } else {
            throw Exception("Failed to fetch all hadiths");
          }
        }
      }
      //save data
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/sahih-muslim.json");
      await file.writeAsString(
        jsonEncode({"book": "sahih-muslim", "chapters": chapterlist}),
      );
    } catch (e) {
      throw Exception("here is error ${e.toString()}");
    }
  }
}
