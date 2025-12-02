// import 'package:Muslim/Core/Services/rewarded_ad_services.dart';
// import 'package:flutter/material.dart';

// class ShowAds extends StatefulWidget {
//   const ShowAds({super.key});

//   @override
//   State<ShowAds> createState() => _ShowAdsState();
// }

// class _ShowAdsState extends State<ShowAds> {
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Ensure ad starts loading when page opens
//     RewardedAdServices.adLoading();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: TextButton(
//           onPressed: () {
//             RewardedAdServices.showRewardAd(
//               context: context,
//               onUserEarnedReward: (rewardCoins) {
//                 debugPrint("🎉 User earned $rewardCoins coins!");
//               },
//             );
//           },
//           child: const Text("Show Rewarded Ad", style: TextStyle(fontSize: 18)),
//         ),
//       ),
//     );
//   }
// }
