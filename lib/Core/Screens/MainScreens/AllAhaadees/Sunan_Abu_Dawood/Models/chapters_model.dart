class SunanChapters {
  int? status;
  String? message;
  List<Chapters>? chapters;

  SunanChapters({this.status, this.message, this.chapters});

  SunanChapters.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['chapters'] != null) {
      chapters = <Chapters>[];
      json['chapters'].forEach((v) {
        chapters!.add(new Chapters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.chapters != null) {
      data['chapters'] = this.chapters!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chapters {
  int? id;
  String? chapterNumber;
  String? chapterEnglish;
  String? chapterUrdu;
  String? chapterArabic;
  String? bookSlug;

  Chapters({
    this.id,
    this.chapterNumber,
    this.chapterEnglish,
    this.chapterUrdu,
    this.chapterArabic,
    this.bookSlug,
  });

  Chapters.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chapterNumber = json['chapterNumber'];
    chapterEnglish = json['chapterEnglish'];
    chapterUrdu = json['chapterUrdu'];
    chapterArabic = json['chapterArabic'];
    bookSlug = json['bookSlug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chapterNumber'] = this.chapterNumber;
    data['chapterEnglish'] = this.chapterEnglish;
    data['chapterUrdu'] = this.chapterUrdu;
    data['chapterArabic'] = this.chapterArabic;
    data['bookSlug'] = this.bookSlug;
    return data;
  }
}
