import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart'; // Image banane ke liye
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
  // 1. Controller jo widget ki photo kheechega
  ScreenshotController screenshotController = ScreenshotController();

  Color selectedColor = Colors.teal.shade900; // Default background color
  double fontSize = 20; // Default Arabic font size

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Share Post")),
      body: Column(
        children: [
          // --- POST PREVIEW AREA ---
          Expanded(
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: 350, // Square post size
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(0), // Social media look
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Hadith # ${widget.hadithNo}",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // ARABIC TEXT
                        Text(
                          widget.arabic,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            // Khoobsurat Arabic Font
                            color: Colors.white,
                            fontSize: fontSize,
                            height: 1.8,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        // ENGLISH/URDU TEXT
                        Text(
                          widget.english,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // APP BRANDING
                        const Text(
                          "Shared via Digital Tasbeeh App",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Customize Post",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                // Color Picker Row
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _colorOption(Colors.black),
                      _colorOption(Colors.teal.shade900),
                      _colorOption(Colors.brown.shade800),
                      _colorOption(Colors.blueGrey.shade900),
                      _colorOption(Colors.red.shade900),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Font Size Slider
                Row(
                  children: [
                    const Icon(Icons.format_size),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: 15,
                        max: 35,
                        onChanged: (val) => setState(() => fontSize = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // FINAL SHARE BUTTON
                ElevatedButton.icon(
                  onPressed: _takeScreenshotAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    "Share to WhatsApp / FB",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Color option widget
  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }

  // --- LOGIC: CAPTURE & SHARE ---
  void _takeScreenshotAndShare() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/hadith_post.png',
      ).create();
      await imagePath.writeAsBytes(image);

      // Share the image file
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Read this beautiful Hadith');
    }
  }
}
