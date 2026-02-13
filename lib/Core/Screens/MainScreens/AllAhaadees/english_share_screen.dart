import 'dart:io';
import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class EnglishShareScreen extends StatefulWidget {
  final String arabic;
  final String english;
  final String hadithNo;

  const EnglishShareScreen({
    super.key,
    required this.arabic,
    required this.english,
    required this.hadithNo,
  });

  @override
  State<EnglishShareScreen> createState() => _EnglishShareScreenState();
}

class _EnglishShareScreenState extends State<EnglishShareScreen> {
  // Images ki list
  final List<String> bgimages = [
    AppImages.rmbg1,
    AppImages.rmbg2,
    AppImages.rmbg3,
    AppImages.rmbg4,
    AppImages.rmbg5,
  ];

  ScreenshotController screenshotController = ScreenshotController();

  // Customization States
  late String selectedBgImage;
  Color selectedTextColor = Colors.black; // Ab colors text ke liye hain
  double fontSize = 22;

  @override
  void initState() {
    super.initState();
    selectedBgImage = bgimages[0]; // Pehli image default hogi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Create Hadith Post"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- POST PREVIEW AREA ---
          Expanded(
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: double.infinity,
                  height: double.infinity, // Perfect Square for Social Media
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage(selectedBgImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hadith # ${widget.hadithNo}",
                        style: TextStyle(
                          color: selectedTextColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ARABIC TEXT
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  widget.arabic,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.amiri(
                                    color: selectedTextColor,
                                    fontSize: fontSize,
                                    height: 1.6,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Divider(
                                    color: selectedTextColor.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                // ENGLISH TEXT
                                Text(
                                  widget.english,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedTextColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Shared via Digital Tasbeeh App",
                        style: TextStyle(
                          color: selectedTextColor.withOpacity(0.5),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- CONTROLS AREA ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background Image Selector
                const Text(
                  "Select Background",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bgimages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedBgImage = bgimages[index]),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedBgImage == bgimages[index]
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetImage(bgimages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Text Color Selector

                // Font Size Slider
                Row(
                  children: [
                    const Icon(Icons.format_size, size: 20),
                    Expanded(
                      child: Slider(
                        activeColor: Colors.green,
                        value: fontSize,
                        min: 18,
                        max: 32,
                        onChanged: (val) => setState(() => fontSize = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _takeScreenshotAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text(
                    "SHARE TO SOCIAL MEDIA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedTextColor = color),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedTextColor == color
                ? Colors.green
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _takeScreenshotAndShare() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/hadith_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Read this beautiful Hadith');
    }
  }
}
