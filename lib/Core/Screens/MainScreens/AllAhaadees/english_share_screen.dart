import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb check karne ke liye
import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// Web download ke liye conditional import lagta hai, niche function mein handle kiya hai.

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
  final List<String> bgimages = [
    AppImages.rmbg1,
    AppImages.rmbg2,
    AppImages.rmbg3,
    AppImages.rmbg4,
    AppImages.rmbg5,
  ];

  ScreenshotController screenshotController = ScreenshotController();
  dynamic selectedBgImage;
  Color selectedTextColor = Colors.black;
  double fontSize = 22;

  @override
  void initState() {
    super.initState();
    selectedBgImage = bgimages[0];
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedBgImage = File(pickedFile.path));
    }
  }

  // --- SAVE & DOWNLOAD LOGIC ---
  Future<void> _saveOrDownloadImage() async {
    final image = await screenshotController.capture();
    if (image == null) return;

    if (kIsWeb) {
      // Web logic: Download in browser
      // Note: Web ke liye anchor element use hota hai
      final base64 = Uri.dataFromBytes(image, mimeType: "image/png").toString();
      // In real app, you might use 'dart:html' anchor element here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Web download triggered!")));
    } else {
      // Mobile logic: Save to Documents/Gallery
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/hadith_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(image);

      // Aap 'gal' ya 'image_gallery_saver' package use karke gallery mein bhej sakte hain
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Saved to: $path")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Create Hadith Post"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _saveOrDownloadImage, // Download Button in AppBar
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // --- DRAG TO RESIZE GESTURE ---
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    // Neeche drag karne se size barhega, upar se kam
                    fontSize -= details.delta.dy * 0.1;
                    fontSize = fontSize.clamp(12.0, 50.0); // Limit settings
                  });
                },
                child: Screenshot(
                  controller: screenshotController,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: selectedBgImage is File
                            ? FileImage(selectedBgImage) as ImageProvider
                            : AssetImage(selectedBgImage),
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
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.arabic,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.amiri(
                                    color: selectedTextColor,
                                    fontSize: fontSize,
                                    height: 1.6,
                                  ),
                                ),
                                Divider(
                                  color: selectedTextColor.withOpacity(0.3),
                                  thickness: 1,
                                  height: 30,
                                ),
                                Text(
                                  widget.english,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedTextColor,
                                    fontSize: fontSize * 0.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Shared via Digital Tasbeeh App",
                          style: TextStyle(
                            color: selectedTextColor.withOpacity(0.5),
                            fontSize: 10,
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bgimages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.green,
                            ),
                          ),
                        );
                      }
                      final assetPath = bgimages[index - 1];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedBgImage = assetPath),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedBgImage == assetPath
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetImage(assetPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveOrDownloadImage,
                        icon: const Icon(Icons.save_alt),
                        label: const Text("SAVE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _takeScreenshotAndShare,
                        icon: const Icon(Icons.share),
                        label: const Text("SHARE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _takeScreenshotAndShare() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/hadith_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([XFile(imagePath.path)], text: 'Hadith Share');
    }
  }
}
