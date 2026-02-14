import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:universal_html/html.dart' as html;

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
  Uint8List? webImage;
  File? _pickedFile;
  Color selectedTextColor = Colors.black;
  double fontSize = 24.0; // Default size

  @override
  void initState() {
    super.initState();
    selectedBgImage = bgimages[0];
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
          selectedBgImage =
              "web_custom"; // Yeh marker bataey ga ke web image use karni hai
        });
      } else {
        setState(() {
          _pickedFile = File(pickedFile.path);
          selectedBgImage = _pickedFile; // Mobile ke liye File object
        });
      }
    }
  }

  Future<void> _downloadImage() async {
    final image = await screenshotController.capture();
    if (image == null) return;
    try {
      if (kIsWeb) {
        final base64 = base64Encode(image);
        final anchor =
            html.AnchorElement(
                href:
                    'data:application/octet-stream;charset=utf-16le;base64,$base64',
              )
              ..setAttribute(
                "download",
                "hadith_${DateTime.now().millisecondsSinceEpoch}.png",
              )
              ..click();
      } else {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/hadith_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(image);
        await Gal.putImage(imagePath);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Congratulations! Saved successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text("Create Hadith Post"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_for_offline,
              size: 28,
              color: Colors.blue,
            ),
            onPressed: _downloadImage,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image:
                        (kIsWeb &&
                            selectedBgImage == "web_custom" &&
                            webImage != null)
                        ? MemoryImage(webImage!)
                              as ImageProvider // Web Gallery ke liye
                        : (selectedBgImage is File)
                        ? FileImage(
                            selectedBgImage as File,
                          ) // Mobile Gallery ke liye
                        : AssetImage(
                            selectedBgImage.toString(),
                          ), // Assets ke liye
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Hadith # ${widget.hadithNo}",
                      style: TextStyle(
                        color: selectedTextColor.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                child: Divider(
                                  color: selectedTextColor.withOpacity(0.3),
                                  thickness: 1,
                                  indent: 60,
                                  endIndent: 60,
                                ),
                              ),
                              Text(
                                widget.english,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selectedTextColor,
                                  fontSize: fontSize * 0.65,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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

          // --- CONTROLS AREA ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- FONT SIZE SLIDER (New Feature) ---
                Row(
                  children: [
                    const Icon(Icons.text_fields, size: 20, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: 14.0,
                        max: 60.0,
                        activeColor: Colors.green,
                        inactiveColor: Colors.green.withOpacity(0.2),
                        onChanged: (value) {
                          setState(() {
                            fontSize = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      "${fontSize.toInt()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Background Selector
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kIsWeb ? 1 : bgimages.length + 1,
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
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
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
                const SizedBox(height: 20),
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
