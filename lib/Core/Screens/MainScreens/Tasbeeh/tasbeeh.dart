import 'package:muslim/Core/Services/ad_controller.dart';
import 'package:muslim/Core/Services/rewarded_ad_services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:muslim/Core/Const/app_images.dart';
import 'package:muslim/Core/Const/apptextstyle.dart';
import 'package:muslim/Core/Screens/MainScreens/Tasbeeh/tasbeehbeads.dart';
import 'package:muslim/Core/Widgets/Buttons/containerbutton.dart';
import 'package:muslim/Core/Widgets/Buttons/customtextbutton.dart';
import 'package:muslim/Core/Widgets/Buttons/iconbutton.dart';
import 'package:muslim/Core/Widgets/Containers/container0.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibration/vibration.dart';

class Tasbeeh extends StatefulWidget {
  const Tasbeeh({super.key});

  @override
  State<Tasbeeh> createState() => _TasbeehState();
}

class _TasbeehState extends State<Tasbeeh> {
  // Azkar
  final List<String> azkaar = [
    "سبحان اللہ",
    "الحمد للہ",
    "اللہ اکبر",
    "لا الہ الا اللہ",
    "استغفر اللہ",
    "سبحان اللہ وبحمدہ سبحان اللہ العظیم",
    "لا حول ولا قوۃ الا باللہ",
    "للَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ",
  ];

  // Azkar meaning
  final List<String> azkarmean = [
    "Glory be to Allah",
    "Praise be to God",
    "God is greater",
    "There is no god but Allah",
    "I ask God for forgiveness",
    "Glory be to Allah and praise be to Him, Glory be to Allah the Great",
    "There is no power and no strength except with Allah",
    "O Allah, send blessings upon Muhammad and upon the family of Muhammad",
  ];

  int currentIndex = 0;
  int round = 1;
  late List<int> rounds;

  // one counter & selected number per zikr
  late List<int> counters;
  late List<int> selectedNumbers;

  // Fonts, sound, vibration
  double fontsize = 25;
  bool soundselected = false;
  bool selectvibr = false;

  final TextEditingController numbercontroller = TextEditingController();
  final GlobalKey<AnimatedBeadsCounterState> beadsKey =
      GlobalKey<AnimatedBeadsCounterState>();

  @override
  void initState() {
    super.initState();
    // RewardedAdServices.adLoading();
    counters = List.filled(azkaar.length, 0);
    selectedNumbers = List.filled(azkaar.length, 33);
    rounds = List.filled(azkaar.length, 1);

    getdata();
  }

  Future<void> savedata() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "counters",
      counters.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      "selectedNumbers",
      selectedNumbers.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      "rounds", // ✅ save rounds as string list
      rounds.map((e) => e.toString()).toList(),
    );
    await prefs.setInt("selectedZikr", currentIndex);
    await prefs.setInt("Round", round);
  }

  Future<void> getdata() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCounters = prefs.getStringList("counters");
    final savedNumbers = prefs.getStringList("selectedNumbers");
    final savedRounds = prefs.getStringList("rounds"); // ✅ key matches savedata

    setState(() {
      counters = savedCounters != null
          ? savedCounters.map((e) => int.tryParse(e) ?? 0).toList()
          : List.filled(azkaar.length, 0);

      selectedNumbers = savedNumbers != null
          ? savedNumbers.map((e) => int.tryParse(e) ?? 33).toList()
          : List.filled(azkaar.length, 33);

      rounds = savedRounds != null
          ? savedRounds.map((e) => int.tryParse(e) ?? 1).toList()
          : List.filled(azkaar.length, 1);

      currentIndex = prefs.getInt("selectedZikr") ?? 0;
      round = rounds[currentIndex]; // ✅ show saved round
    });
  }

  //zkar plus and min
  //saved in watsapp

  void goNext() {
    setState(() {
      if (currentIndex < azkaar.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // loop back to first
      }

      // Update round to match the new Zikr
      round = rounds[currentIndex];
    });
    savedata();
  }

  //go previous saved in watsapp
  void goprevious() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        // loop back to last
        currentIndex = azkaar.length - 1;
      }

      // Update round to match the new Zikr
      round = rounds[currentIndex];
    });
    savedata();
  }

  // Counter functions
  void counterplus() {
    setState(() {
      if (counters[currentIndex] < selectedNumbers[currentIndex]) {
        counters[currentIndex]++;
      } else {
        round++;
        rounds[currentIndex]++;
        counters[currentIndex] = 0;
      }
    });
    savedata();
  }

  void countermin() {
    setState(() {
      if (counters[currentIndex] > 0) counters[currentIndex]--;
    });
    savedata();
  }

  void refresher() {
    setState(() {
      counters[currentIndex] = 0;
      rounds[currentIndex] = 1;
      round = 1;
    });
    savedata();
  }

  //here is defined  colors
  List<Color> tasbehcolor = [
    Color(0Xff7851A9),
    Color(0XffFFD700),
    Color(0Xff4169E1),
    Color(0XffDC143C),
    Color(0Xff50C878),
    Color(0Xff0D0D0D),
    Color(0XffFFFFF0),
    Color(0Xff722F37),
  ];
  int selectedcolour = 4;

  // here is tick tick
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> tick() async {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.play(AssetSource("audios/tiktiktik.mp3"));
  }

  Future<void> vibr() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }
  }

  TextEditingController zikrcontroller = TextEditingController();
  TextEditingController transcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0,
            vertical: height * 0.010,
          ),
          child: Column(
            children: [
              Gap(height * 0.012),
              // Top Container with refresh, sound, vibration, font
              Container(
                height: height * 0.12,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.010),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // RewardedAdServices.showRewardAd(
                          //   onUserEarnedReward: (rewardCoinsd) {
                          //     debugPrint("User earned $rewardCoinsd");
                          //   },
                          // );

                          AdController().tryShowAd();

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Tasbeeh",
                          style: Apptextstyle.title.copyWith(
                            color: Colors.black54,
                            letterSpacing: 2,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Spacer(),

                      //save iconbutton0 that below saved in watsapp
                      IconButton0(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text("Reset Options"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. Reset Current Counter
                                    CustomTextButton(
                                      onPressed: () {
                                        setState(() {
                                          counters[currentIndex] = 0;
                                        });
                                        savedata();
                                        // RewardedAdServices.showRewardAd(
                                        //   onUserEarnedReward: (rewardCoins) {
                                        //     debugPrint(
                                        //       "User gets reward $rewardCoins",
                                        //     );
                                        //   },
                                        // );

                                        AdController().tryShowAd();

                                        Navigator.pop(context);
                                      },
                                      bchild: const Text(
                                        "Reset Current Counter",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),

                                    // 2. Reset All Counters
                                    CustomTextButton(
                                      onPressed: () {
                                        setState(() {
                                          counters = List.filled(
                                            azkaar.length,
                                            0,
                                          );
                                        });
                                        savedata();
                                        // RewardedAdServices.showRewardAd(
                                        //   onUserEarnedReward: (rewardCoins) {
                                        //     debugPrint(
                                        //       "User gets reward $rewardCoins",
                                        //     );
                                        //   },
                                        // );

                                        AdController().tryShowAd();

                                        Navigator.pop(context);
                                      },
                                      bchild: const Text(
                                        "Reset All Counters",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),

                                    // 3. Reset Current Round
                                    CustomTextButton(
                                      onPressed: () {
                                        setState(() {
                                          round = 1;
                                        });
                                        savedata();
                                        // RewardedAdServices.showRewardAd(
                                        //   onUserEarnedReward: (rewardCoins) {
                                        //     debugPrint(
                                        //       "User gets reward $rewardCoins",
                                        //     );
                                        //   },
                                        // );

                                        AdController().tryShowAd();

                                        Navigator.pop(context);
                                      },
                                      bchild: const Text(
                                        "Reset Current Round",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),

                                    // 4. Reset All Rounds
                                    CustomTextButton(
                                      onPressed: () {
                                        setState(() {
                                          round = 1;
                                          // If you have rounds list per zikr
                                          rounds = List.filled(
                                            azkaar.length,
                                            1,
                                          );
                                        });
                                        savedata();
                                        // RewardedAdServices.showRewardAd(
                                        //   onUserEarnedReward: (rewardCoins) {
                                        //     debugPrint(
                                        //       "User gets $rewardCoins",
                                        //     );
                                        //   },
                                        // );
                                        AdController().tryShowAd();

                                        Navigator.pop(context);
                                      },
                                      bchild: const Text(
                                        "Reset All Rounds",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),

                                    // Optional Cancel Button
                                    CustomTextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      bchild: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        bicon: const Icon(
                          Icons.refresh,
                          size: 25,
                          color: Colors.black54,
                        ),
                      ),
                      IconButton0(
                        bicon: Icon(
                          soundselected
                              ? CupertinoIcons.volume_mute
                              : CupertinoIcons.volume_up,
                          size: 25,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            soundselected = !soundselected;
                          });
                        },
                      ),
                      IconButton0(
                        bicon: selectvibr
                            ? Icon(
                                CupertinoIcons.volume_off,
                                size: 25,
                                color: Colors.black54,
                              )
                            : Icon(
                                Icons.vibration,
                                size: 25,
                                color: Colors.black54,
                              ),

                        onPressed: () {
                          setState(() {
                            selectvibr = !selectvibr;
                          });
                        },
                      ),

                      //size changer removed
                      // IconButton0(
                      //   onPressed: () {
                      //     showModalBottomSheet(
                      //       context: context,
                      //       builder: (context) {
                      //         return StatefulBuilder(
                      //           builder: (context, setModalState) {
                      //             return CustomContainer0(
                      //               height: height * 0.12,
                      //               fillcolour: Colors.white,
                      //               child: Column(
                      //                 children: [
                      //                   const Text(
                      //                     "Change Font Size",
                      //                     style: TextStyle(fontSize: 16),
                      //                   ),
                      //                   Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.center,
                      //                     children: [
                      //                       const Text("10"),
                      //                       SizedBox(
                      //                         width: width * 0.8,
                      //                         child: Slider(
                      //                           min: 10,
                      //                           max: 50,
                      //                           divisions: 40,
                      //                           label: fontsize
                      //                               .round()
                      //                               .toString(),
                      //                           value: fontsize,
                      //                           activeColor: Colors.green,
                      //                           onChanged: (value) {
                      //                             setModalState(() {
                      //                               fontsize = value;
                      //                             });
                      //                             setState(() {});
                      //                           },
                      //                         ),
                      //                       ),
                      //                       const Text("50"),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             );
                      //           },
                      //         );
                      //       },
                      //     );
                      //   },
                      //   bicon: const Icon(
                      //     Icons.font_download_outlined,
                      //     size: 30,
                      //     color: Colors.black54,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Gap(height * 0.02),
              // Azkar display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CustomContainer0(
                  height: height * 0.29,
                  widht: double.infinity,
                  fillcolour: Color(0xff59AC77),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: height * 0.009,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                (currentIndex + 1).toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "/",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                azkaar.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          Center(
                            child: Text(
                              azkaar[currentIndex],
                              style: TextStyle(
                                fontSize: fontsize,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton0(
                                onPressed: goprevious,
                                bicon: ImageIcon(
                                  color: Colors.white,
                                  AssetImage(AppImages.backbutton),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.58,
                                child: const Divider(
                                  color: Colors.white,
                                  thickness: 2,
                                ),
                              ),
                              IconButton0(
                                onPressed: goNext,
                                bicon: ImageIcon(
                                  color: Colors.white,

                                  AssetImage(AppImages.backbutton0),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            azkarmean[currentIndex],
                            style: TextStyle(
                              fontSize: fontsize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // ✅ CLICK ANYWHERE = LEFT BEAD TAP (+1)
                              if (!soundselected) tick();
                              if (!selectvibr) vibr();
                              beadsKey.currentState?.triggerLeftBeadTap();
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < 0) {
                                  // ✅ SWIPE LEFT → DECREMENT
                                  // countermin();
                                  if (!soundselected) tick();
                                  if (!selectvibr) vibr();
                                  beadsKey.currentState
                                      ?.triggerRightBeadTap(); // move right bead left
                                } else if (details.primaryVelocity! > 0) {
                                  // ✅ SWIPE RIGHT → INCREMENT
                                  // counterplus();
                                  if (!soundselected) tick();
                                  if (!selectvibr) vibr();
                                  beadsKey.currentState
                                      ?.triggerLeftBeadTap(); // move left bead right
                                }
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: constraints.maxHeight * 0.02,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            counters[currentIndex].toString(),
                                            style: Apptextstyle.title.copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 50,
                                            ),
                                          ),
                                          const Text(
                                            "/",
                                            style: TextStyle(
                                              fontSize: 45,
                                              color: Colors.black38,
                                            ),
                                          ),
                                          Text(
                                            selectedNumbers[currentIndex]
                                                .toString(),
                                            style: Apptextstyle.title.copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Round :"),
                                          Text(" $round"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AspectRatio(
                                  aspectRatio: 2.5,
                                  child: AnimatedBeadsCounter(
                                    key: beadsKey,
                                    beadColor: tasbehcolor[selectedcolour],
                                    onLeftBeadTap: () {
                                      counterplus();
                                      if (!soundselected) tick();
                                      if (!selectvibr) vibr();
                                    },
                                    onRightBeadTap: () {
                                      countermin(); // ✅ CHANGE HERE: right bead tap = decrement
                                      if (!soundselected) tick();
                                      if (!selectvibr) vibr();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Gap(height * 0.05),
            ],
          ),
        ),

        // ---------- REPLACE your bottomSheet: Container(...) with this block ----------
        bottomSheet: Container(
          height: height * 0.10,
          // width: width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // ---------------- Color Picker Button ----------------
                ContainerButton(
                  height: height * 0.075,
                  width: 60,
                  onPressed: () {
                    // Use modal bottom sheet again for consistency
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext ctx) {
                        // ctx is the bottom-sheet context (use this when closing the sheet)
                        return Container(
                          height: height * 0.30,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // header row with cancel / title / done
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton0(
                                      onPressed: () =>
                                          Navigator.pop(ctx), // close sheet
                                      bicon: const Icon(
                                        Icons.cancel,
                                        size: 35,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          "Adjust Round numbers",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    IconButton0(
                                      onPressed: () =>
                                          Navigator.pop(ctx), // close sheet
                                      bicon: const Icon(
                                        Icons.done,
                                        size: 35,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // quick-select buttons row 1
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedNumbers[currentIndex] =
                                                  33;
                                            });
                                            savedata();
                                            Navigator.pop(ctx); // close sheet
                                          },
                                          child: CustomContainer0(
                                            height: 60,
                                            widht: width * 0.45,
                                            fillcolour: Colors.white,
                                            bcolor: Colors.black,
                                            child: Center(
                                              child: Text(
                                                "33",
                                                style: Apptextstyle.title
                                                    .copyWith(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedNumbers[currentIndex] =
                                                  70;
                                            });
                                            savedata();
                                            Navigator.pop(ctx);
                                          },
                                          child: CustomContainer0(
                                            height: 60,
                                            widht: width * 0.45,
                                            fillcolour: Colors.white,
                                            bcolor: Colors.black,
                                            child: Center(
                                              child: Text(
                                                "70",
                                                style: Apptextstyle.title
                                                    .copyWith(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Gap(8),

                                // quick-select buttons row 2
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedNumbers[currentIndex] =
                                                  100;
                                            });
                                            savedata();
                                            Navigator.pop(ctx);
                                          },
                                          child: CustomContainer0(
                                            height: 60,
                                            widht: width * 0.45,
                                            fillcolour: Colors.white,
                                            bcolor: Colors.black,
                                            child: Center(
                                              child: Text(
                                                "100",
                                                style: Apptextstyle.title
                                                    .copyWith(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Customize button opens a dialog (dialogCtx)
                                      Expanded(
                                        child: CustomContainer0(
                                          height: 60,
                                          widht: width * 0.45,
                                          fillcolour: Colors.white,
                                          bcolor: Colors.black,
                                          child: CustomTextButton(
                                            onPressed: () {
                                              // show a dialog on top of the bottom sheet
                                              showDialog(
                                                context:
                                                    ctx, // important: use sheet ctx as parent
                                                builder: (BuildContext dialogCtx) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: Row(
                                                      children: [
                                                        IconButton0(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogCtx,
                                                              ), // close dialog only
                                                          bicon: const Icon(
                                                            Icons.cancel,
                                                            size: 20,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        const Expanded(
                                                          child: Text(
                                                            "Adjust Round numbers",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton0(
                                                          onPressed: () {
                                                            // Save value and then close dialog + bottom sheet
                                                            setState(() {
                                                              selectedNumbers[currentIndex] =
                                                                  int.tryParse(
                                                                    numbercontroller
                                                                        .text,
                                                                  ) ??
                                                                  selectedNumbers[currentIndex];
                                                            });
                                                            savedata();
                                                            Navigator.pop(
                                                              dialogCtx,
                                                            ); // close dialog
                                                            Navigator.pop(
                                                              ctx,
                                                            ); // close bottom sheet
                                                          },
                                                          bicon: const Icon(
                                                            Icons.done,
                                                            size: 20,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: TextField(
                                                      controller:
                                                          numbercontroller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          const InputDecoration(
                                                            hintText:
                                                                "Enter number",
                                                          ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            bchild: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "Customize",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Gap(10),
                                                Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  bchild: Icon(
                    Icons.edit_document,
                    size: height * 0.05,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(),

                // ---------------- Edit / Adjust Round Button ----------------
                ContainerButton(
                  height: height * 0.075,
                  width: 60,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext ctx) {
                        final sheetHeight =
                            MediaQuery.of(ctx).size.height * 0.25;

                        return Container(
                          height: sheetHeight,
                          decoration: const BoxDecoration(
                            color:
                                Colors.white, // ✅ Use visible color for sheet
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: tasbehcolor.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedcolour = index;
                                  });
                                  savedata();
                                  Navigator.pop(ctx); // ✅ safely close sheet
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                      radius:
                                          30, // ✅ slightly smaller to fit better
                                      backgroundColor: tasbehcolor[index],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  bchild: Icon(
                    Icons.color_lens_outlined,
                    size: height * 0.05,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        // RewardedAdServices.showRewardAd(
        //   onUserEarnedReward: (rewardCoins) {
        //     debugPrint("User gets reward $rewardCoins");
        //   },
        // );

        AdController().tryShowAd();

        Navigator.pop(context);
        return false;
      },
    );
  }
}
