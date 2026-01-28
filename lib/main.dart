import 'package:Muslim/Core/Const/app_audio.dart';
import 'package:Muslim/Core/Const/app_images.dart';
import 'package:Muslim/Core/Services/ad_controller.dart';
import 'package:Muslim/splashscreen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  AdController().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Splashscreen(),
    );
  }
}

class Checksomething extends StatefulWidget {
  const Checksomething({super.key});

  @override
  State<Checksomething> createState() => _ChecksomethingState();
}

class _ChecksomethingState extends State<Checksomething> {
  bool ispaused = false;
  late AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _positon = Duration.zero;

  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _player.setSource(AssetSource(AppAudio.testingaudio));
    });
    _player.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _player.onPositionChanged.listen((p) {
      setState(() {
        _positon = p;
      });
    });
    _player.onPlayerComplete.listen((event) {
      setState(() {
        ispaused = true;
        _positon = Duration.zero;
      });
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Gap(15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(formatTime(_positon)),
                          Gap(2),
                          SizedBox(
                            width: 240,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ), // smaller thumb
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 8,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: _duration.inMilliseconds.toDouble(),
                                value: _positon.inMilliseconds.toDouble().clamp(
                                  0,
                                  _duration.inMilliseconds.toDouble(),
                                ),
                                onChanged: (value) async {
                                  final _positon = Duration(
                                    milliseconds: value.toInt(),
                                  );
                                  await _player.seek(_positon);
                                },
                                activeColor: Colors.black,
                              ),
                            ),
                          ),
                          Gap(2),
                          Text(formatTime(_duration)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final newPosition =
                                  (_positon ?? Duration.zero) -
                                  const Duration(seconds: 10);
                              await _player.seek(
                                newPosition < Duration.zero
                                    ? Duration.zero
                                    : newPosition,
                              );
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                            ),
                          ),
                          Gap(10),
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  ispaused = !ispaused;
                                });
                                if (ispaused) {
                                  await _player.pause();
                                } else {
                                  _player.resume();
                                }
                              },
                              icon: Icon(
                                ispaused ? Icons.play_arrow_sharp : Icons.pause,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Gap(10),
                          IconButton(
                            onPressed: () async {
                              final newPosition =
                                  (_positon ?? Duration.zero) +
                                  const Duration(seconds: 10);
                              final maxPosition = _duration ?? Duration.zero;
                              await _player.seek(
                                newPosition > maxPosition
                                    ? maxPosition
                                    : newPosition,
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Surat Al-Fatihah",
                                style: TextStyle(fontSize: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: Text(
                                  "Mahmood Khaleel Al-Husary",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
