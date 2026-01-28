import 'package:muslim/Core/Const/app_images.dart';
import 'package:muslim/Core/Services/carddetails.dart';
import 'package:muslim/Core/Widgets/Buttons/iconbutton.dart';
import 'package:muslim/Core/Widgets/Containers/container0.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Packagepurchase extends StatefulWidget {
  const Packagepurchase({super.key});

  @override
  State<Packagepurchase> createState() => _PackagepurchaseState();
}

class _PackagepurchaseState extends State<Packagepurchase> {
  List<String> offername = ["Monthly", "Semi Annually", "Annually"];
  List<String> amount = ["PKR 400", "PKR 1,000", "PKR 2,000"];
  List<String> years = ["Per Month*", "Per 6 Month*", "Per Year*"];
  bool isBestSelected = false;

  int? selectedindex;
  String? selectedname;
  String? selectedprice;
  String? selectedduration;

  void _showmodelbottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: ContinuousRectangleBorder(),
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;
        return SizedBox(
          height: height * 0.40,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Text(
                  "Google Play",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              Divider(height: 15, color: Colors.black, indent: 5),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image(
                      height: 60,
                      width: 60,
                      image: AssetImage(AppImages.applogo),
                    ),
                    Gap(10),
                    Column(
                      children: [
                        Text(
                          selectedname ?? "",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(selectedduration ?? ""),
                      ],
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          selectedprice ?? "",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text("+tax"),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.black),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Carddetailspayment(
                          packageduration: selectedduration,
                          packagename: selectedname,
                          packageprice: selectedprice,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text("SadaPay", style: TextStyle(fontSize: 20)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios_outlined),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.black),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Tap Buy to complete your purchese.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Gap(15),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(15),
                    ),
                    backgroundColor: Colors.green,
                    fixedSize: Size(width * 1, height * 0.06),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text("You have purchesed offer"),
                      ),
                    );
                  },

                  child: Text(
                    "Buy",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Gap(height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Become a Ads free User",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      IconButton0(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        bicon: Icon(Icons.cancel, color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                ),
                Image(
                  height: height * 0.25,
                  image: AssetImage(AppImages.admuteimage),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        letterSpacing: 1,

                        wordSpacing: 2,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "Tired of ads? Upgrade to Premium for a completely  ",
                          // style: TextStyle(color: Colors.black),
                        ),

                        TextSpan(
                          text: "ads-free",

                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        TextSpan(
                          text: "  experience!",
                          // style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBestSelected = !isBestSelected;
                      selectedindex = null;
                    });
                    if (isBestSelected) {
                      selectedname = "Best Offer";
                      selectedprice = "Rs. 11000";
                      selectedduration = "3-Years Pro";
                    } else {
                      selectedname = null;
                      selectedprice = null;
                    }
                  },
                  child: CustomContainer0(
                    fillcolour: isBestSelected
                        ? Colors.green.shade100
                        : Colors.white,
                    bcolor: Colors.black54,

                    widht: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Gap(2),
                        Text("Best Offer", style: TextStyle(fontSize: 17)),
                        Gap(3),
                        Text(
                          "Pkr 11000",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),

                        Text("3-Years Pro", style: TextStyle(fontSize: 17)),
                        Gap(2),
                      ],
                    ),
                  ),
                ),
                GridView.builder(
                  itemCount: offername.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = selectedindex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isBestSelected = false;
                            if (selectedindex == index) {
                              selectedindex = null; // tap again → unselect
                              selectedname = null;
                              selectedprice = null;
                              selectedduration = null;
                            } else {
                              selectedindex = index; // select this one
                              selectedname = offername[index];
                              selectedprice = amount[index];
                              selectedduration = years[index];
                            }
                          });
                        },

                        child: CustomContainer0(
                          fillcolour: isSelected
                              ? Colors.green.shade100
                              : Colors.white,
                          bcolor: Colors.black54,
                          child: Column(
                            children: [
                              Gap(10),
                              Text(offername[index]),
                              Spacer(),
                              Text(
                                amount[index],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Spacer(),
                              Text(years[index]),
                              Gap(10),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Gap(height * 0.05),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(15),
                    ),
                    backgroundColor: Colors.green,
                    fixedSize: Size(width * 1, height * 0.08),
                  ),
                  onPressed: () {
                    if (selectedname != null || selectedprice != null) {
                      _showmodelbottomsheet(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          elevation: 2,
                          duration: Duration(seconds: 1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                          content: Text("Please Select an Offer Before..|"),
                        ),
                      );
                    }
                  },

                  child: Text(
                    "Subscribe",
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: 10,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        letterSpacing: 1,

                        wordSpacing: 2,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: "By subscribing you also agreed to our ",
                          // style: TextStyle(color: Colors.black),
                        ),

                        TextSpan(
                          text: "Terms Of Use ",

                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        TextSpan(text: "&"),
                        TextSpan(
                          text: " Privacy Policy",
                          // style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        // Navigator.pop(context);
        return false;
      },
    );
  }
}
