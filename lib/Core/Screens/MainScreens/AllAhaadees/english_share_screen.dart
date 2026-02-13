import 'dart:io';
import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Gallery ke liye

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

  // Dynamic rakha hai taake Gallery file ya Asset string dono chal saken
  dynamic selectedBgImage;
  Color selectedTextColor = Colors.black;
  double fontSize = 22;

  @override
  void initState() {
    super.initState();
    selectedBgImage = bgimages[0];
  }

  // Gallery se image pick karne ka function
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedBgImage = File(pickedFile.path);
      });
    }
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
          Expanded(
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      // Logic: Agar File hai to FileImage, warna AssetImage
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
                const Text(
                  "Select Background",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // +1 kiya hai gallery button ke liye
                    itemCount: bgimages.length + 1,
                    itemBuilder: (context, index) {
                      // Pehla button Gallery picker hoga
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.green,
                            ),
                          ),
                        );
                      }

                      // Baqi normal asset images
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
                                  : Colors.grey.shade300,
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

  // _colorOption aur _takeScreenshotAndShare functions wese hi rahen ge
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
