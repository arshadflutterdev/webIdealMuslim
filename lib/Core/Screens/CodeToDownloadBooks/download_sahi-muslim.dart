import 'dart:convert';

import 'package:Muslim/Core/Screens/MainScreens/AllAhaadees/HadeesinUrdu/SahiBukhari/hadith_details_model.dart';
import 'package:http/http.dart' as http;

class DownloadSahimuslim {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> downloadsahimuslim() async {
    final muslimresponse = await http.get(
      Uri.parse(
        "https://hadithapi.com/api/sahih-muslim/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
      ),
    );
    if (muslimresponse.statusCode == 200) {
      final chapterjson = jsonDecode(muslimresponse.body);
      final muslimchapters = chapterjson["chapters"] ?? [];
      for (var hadiths in muslimchapters) {
        final chaptersNo = hadiths["chapterNumber"];
        final hadithresponse = await http.get(
          Uri.parse(
            "https://hadithapi.com/api/hadiths/?book=sahih-muslim&chapter=$chaptersNo&apiKey=$apiKey",
          ),
        );
        if (hadithresponse.statusCode == 200) {
          final hadithdata = jsonDecode(hadithresponse.body);
          hadiths["hadiths"] = hadithdata["hadiths"]["data"];
        } else {
          throw Exception("Failed to fetch all hadiths");
        }
      }
    }
  }
}
