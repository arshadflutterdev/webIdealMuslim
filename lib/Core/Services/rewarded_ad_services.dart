// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class RewardedAdServices {
//   static RewardedAd? _rewardedAd;
//   static bool _isLoading = false;

//   /// ✅ Load the rewarded ad
//   static void adLoading() {
//     // Prevent duplicate loading
//     if (_isLoading || _rewardedAd != null) return;
//     _isLoading = true;

//     RewardedAd.load(
//       adUnitId:
//           "ca-app-pub-3940256099942544/5224354917", // ✅ test rewarded ad id
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) {
//           debugPrint("✅ Rewarded Ad loaded successfully");
//           _rewardedAd = ad;
//           _isLoading = false;

//           // Setup full-screen content callbacks
//           _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (ad) {
//               debugPrint("ℹ️ Ad dismissed");
//               ad.dispose();
//               _rewardedAd = null;
//               adLoading(); // Load the next ad automatically
//             },
//             onAdFailedToShowFullScreenContent: (ad, error) {
//               debugPrint("❌ Failed to show ad: $error");
//               ad.dispose();
//               _rewardedAd = null;
//               adLoading();
//             },
//           );
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint("❌ Failed to load rewarded ad: $error");
//           _isLoading = false;
//           _rewardedAd = null;
//         },
//       ),
//     );
//   }

//   /// ✅ Show the rewarded ad from anywhere
//   static void showRewardAd({
//     required Function(int rewardCoins) onUserEarnedReward,
//     BuildContext? context,
//   }) {
//     if (_rewardedAd != null) {
//       _rewardedAd!.show(
//         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//           // ✅ Corrected: reward.amount instead of reward.rewardCoins
//           onUserEarnedReward(reward.amount.toInt());
//         },
//       );

//       // After showing, clear the ad and preload the next one
//       _rewardedAd = null;
//       adLoading();
//     } else {
//       debugPrint("⚠️ Rewarded Ad not ready yet!");
//       if (context != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Ad not ready yet. Please try again later."),
//           ),
//         );
//       }
//       adLoading();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdServices {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  /// ✅ Load a rewarded ad if not already loading
  static void adLoading() {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    RewardedAd.load(
      // adUnitId: "ca-app-pub-3629224446793734/5928752829", // ✅ Test Ad Unit
      adUnitId: "ca-app-pub-3629224446793734~7182603671", // ✅ Test Ad Unit
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("✅ Rewarded Ad loaded successfully!");
          _rewardedAd = ad;
          _isLoading = false;

          // Reload ad after closing
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("ℹ️ Ad closed by user");
              ad.dispose();
              _rewardedAd = null;
              adLoading(); // load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Ad failed to show: $error");
              ad.dispose();
              _rewardedAd = null;
              adLoading();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Failed to load ad: $error");
          _isLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// ✅ Show rewarded ad anywhere
  static void showRewardAd({
    required Function(int rewardCoins) onUserEarnedReward,
    BuildContext? context,
  }) {
    if (_rewardedAd == null) {
      debugPrint("⚠️ Rewarded ad not ready yet. Loading...");
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ad not ready yet, please wait...")),
        );
      }
      adLoading(); // trigger load if missing
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint("🎁 User earned ${reward.amount.toInt()} coins!");
        onUserEarnedReward(reward.amount.toInt());
      },
    );

    // Clear and preload next ad
    _rewardedAd = null;
    adLoading();
  }
}
