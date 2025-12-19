import 'dart:convert';

import 'package:http/http.dart' as http;

class DownloadJamialtirmidhi {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> downloadjamiatirmidhi() async {
    final getResponse = await http.get(
      Uri.parse(
        "https://hadithapi.com/api/al-tirmidhi/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte",
      ),
    );
    if (getResponse.statusCode == 200) {
      final responsedecode = jsonDecode(getResponse.body);
      final chapterlist = responsedecode["chapters"] ?? [];
      for (var hadiths in chapterlist) {
        final chapterNo = hadiths["chapterNumber"];
        final hadithresponse = await http.get(
          Uri.parse(
            "https://hadithapi.com/api/hadiths/?book=al-tirmidhi&chapter=$chapterNo&apiKey=$apiKey",
          ),
        );
        if (hadithresponse.statusCode == 200) {
          final hadithdecode = jsonDecode(hadithresponse.body);
          hadiths["hadiths"] = hadithdecode["hadiths"]["data"];
        } else {
          throw Exception("failed to fetch hadits");
        }
      }
    }
  }
}
