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

  // States
  dynamic selectedBg; // String (Asset) ya File (Gallery) ho sakta hai
  Color selectedTextColor = Colors.white;
  double fontSize = 22;

  @override
  void initState() {
    super.initState();
    selectedBg = bgimages[0];
  }

  // Gallery se image pick karne ka function
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedBg = File(pickedFile.path); // File set kar di
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for focus
      appBar: AppBar(
        title: const Text("Edit Post"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Post Preview Area
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: 380,
                  height: 380,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    image: DecorationImage(
                      image: selectedBg is File
                          ? FileImage(selectedBg) as ImageProvider
                          : AssetImage(selectedBg),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Hadith # ${widget.hadithNo}",
                        style: TextStyle(
                          color: selectedTextColor.withOpacity(0.7),
                          fontSize: 12,
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
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 5,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: selectedTextColor.withOpacity(0.3),
                                  height: 30,
                                ),
                                Text(
                                  widget.english,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedTextColor,
                                    fontSize: 15,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 5,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

          // 2. Draggable Bottom Sheet (Controls)
          DraggableScrollableSheet(
            initialChildSize: 0.35, // Kitna khula hoga shuru mein
            minChildSize: 0.1, // Kitna chupa sakte hain
            maxChildSize: 0.6, // Full drag pe kitna ooper jaye
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Handle Bar (User ko drag karne ka ishara)
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Background Selection Row
                    const Text(
                      "Background Image",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Gallery Button
                          GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          // List of Asset Images
                          ...bgimages
                              .map(
                                (img) => GestureDetector(
                                  onTap: () => setState(() => selectedBg = img),
                                  child: Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selectedBg == img
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(img),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Text Color",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildColorRow(),

                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: _takeScreenshotAndShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        "SHARE POST",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow() {
    List<Color> colors = [
      Colors.white,
      Colors.yellow,
      Colors.cyanAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.black,
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => setState(() => selectedTextColor = colors[i]),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedTextColor == colors[i]
                    ? Colors.green
                    : Colors.grey,
                width: 2,
              ),
            ),
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
        '${directory.path}/hadith_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([XFile(imagePath.path)], text: 'Hadith Post');
    }
  }
}
