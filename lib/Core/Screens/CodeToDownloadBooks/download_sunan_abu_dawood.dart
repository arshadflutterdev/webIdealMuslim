import 'dart:convert';

import 'package:http/http.dart' as http;

class DownloadSunanAbuDawood {
  final String apiKey =
      "%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte";

  Future<void> getdownload() async {
    final response = await http.get(
      Uri.parse(
        'https://hadithapi.com/api/abu-dawood/chapters?apiKey=%242y%2410%24pk5MeOVosBVG5x5EgPZQOuYdd4Mo6JFFrVOT2z9xGA9oAO4eu6rte',
      ),
    );
    if (response.statusCode == 200) {
      final responsedecode = jsonDecode(response.body);
      final chapterlist = responsedecode["chapters"] ?? [];
      for (var hadiths in chapterlist) {
        final chapterno = hadiths["chapterNumber"];
        final hadithresponse = await http.get(
          Uri.parse(
            "https://hadithapi.com/api/hadiths/?book=abu-dawood&chapter=$chapterno&apiKey=$apiKey",
          ),
        );
        if (hadithresponse.statusCode == 200) {
          final hadithdecode = jsonDecode(hadithresponse.body);
          hadiths["hadiths"] = hadithdecode["hadiths"]["data"];
        } else {
          throw Exception("failed to fetch details");
        }
      }
    }
  }
}
