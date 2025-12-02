class TirmidhiModeldetailed {
  int? status;
  String? message;
  Hadiths? hadiths;

  TirmidhiModeldetailed({this.status, this.message, this.hadiths});

  TirmidhiModeldetailed.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    hadiths = json['hadiths'] != null
        ? new Hadiths.fromJson(json['hadiths'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.hadiths != null) {
      data['hadiths'] = this.hadiths!.toJson();
    }
    return data;
  }
}

class Hadiths {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  Null? prevPageUrl;
  int? to;
  int? total;

  Hadiths({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Hadiths.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data {
  int? id;
  String? hadithNumber;
  String? englishNarrator;
  String? hadithEnglish;
  String? hadithUrdu;
  String? urduNarrator;
  String? hadithArabic;
  String? headingArabic;
  String? headingUrdu;
  String? headingEnglish;
  String? chapterId;
  String? bookSlug;
  String? volume;
  String? status;
  Book? book;
  Chapter? chapter;

  Data({
    this.id,
    this.hadithNumber,
    this.englishNarrator,
    this.hadithEnglish,
    this.hadithUrdu,
    this.urduNarrator,
    this.hadithArabic,
    this.headingArabic,
    this.headingUrdu,
    this.headingEnglish,
    this.chapterId,
    this.bookSlug,
    this.volume,
    this.status,
    this.book,
    this.chapter,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hadithNumber = json['hadithNumber'];
    englishNarrator = json['englishNarrator'];
    hadithEnglish = json['hadithEnglish'];
    hadithUrdu = json['hadithUrdu'];
    urduNarrator = json['urduNarrator'];
    hadithArabic = json['hadithArabic'];
    headingArabic = json['headingArabic'];
    headingUrdu = json['headingUrdu'];
    headingEnglish = json['headingEnglish'];
    chapterId = json['chapterId'];
    bookSlug = json['bookSlug'];
    volume = json['volume'];
    status = json['status'];
    book = json['book'] != null ? new Book.fromJson(json['book']) : null;
    chapter = json['chapter'] != null
        ? new Chapter.fromJson(json['chapter'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hadithNumber'] = this.hadithNumber;
    data['englishNarrator'] = this.englishNarrator;
    data['hadithEnglish'] = this.hadithEnglish;
    data['hadithUrdu'] = this.hadithUrdu;
    data['urduNarrator'] = this.urduNarrator;
    data['hadithArabic'] = this.hadithArabic;
    data['headingArabic'] = this.headingArabic;
    data['headingUrdu'] = this.headingUrdu;
    data['headingEnglish'] = this.headingEnglish;
    data['chapterId'] = this.chapterId;
    data['bookSlug'] = this.bookSlug;
    data['volume'] = this.volume;
    data['status'] = this.status;
    if (this.book != null) {
      data['book'] = this.book!.toJson();
    }
    if (this.chapter != null) {
      data['chapter'] = this.chapter!.toJson();
    }
    return data;
  }
}

class Book {
  int? id;
  String? bookName;
  String? writerName;
  Null? aboutWriter;
  String? writerDeath;
  String? bookSlug;

  Book({
    this.id,
    this.bookName,
    this.writerName,
    this.aboutWriter,
    this.writerDeath,
    this.bookSlug,
  });

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookName = json['bookName'];
    writerName = json['writerName'];
    aboutWriter = json['aboutWriter'];
    writerDeath = json['writerDeath'];
    bookSlug = json['bookSlug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bookName'] = this.bookName;
    data['writerName'] = this.writerName;
    data['aboutWriter'] = this.aboutWriter;
    data['writerDeath'] = this.writerDeath;
    data['bookSlug'] = this.bookSlug;
    return data;
  }
}

class Chapter {
  int? id;
  String? chapterNumber;
  String? chapterEnglish;
  String? chapterUrdu;
  String? chapterArabic;
  String? bookSlug;

  Chapter({
    this.id,
    this.chapterNumber,
    this.chapterEnglish,
    this.chapterUrdu,
    this.chapterArabic,
    this.bookSlug,
  });

  Chapter.fromJson(Map<String, dynamic> json) {
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

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
