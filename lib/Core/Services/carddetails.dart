import 'package:muslim/Core/Const/app_images.dart';
import 'package:muslim/Core/Widgets/TextFields/customtextfield.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Carddetailspayment extends StatefulWidget {
  Carddetailspayment({
    super.key,
    required this.packageduration,
    required this.packagename,
    required this.packageprice,
  });
  final String? packagename;
  final String? packageprice;
  final String? packageduration;

  @override
  State<Carddetailspayment> createState() => _CarddetailspaymentState();
}

TextEditingController cardcontroller = TextEditingController();
TextEditingController cvvcontroller = TextEditingController();
TextEditingController excontroller = TextEditingController();

class _CarddetailspaymentState extends State<Carddetailspayment> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double widht = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Payment Method", style: TextStyle(fontSize: 22)),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context);
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Add SadaPay Card Details to get Offer ❤"),
                ),
              ),
              Gap(10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("All fields required ✔"),
                ),
              ),

              Gap(15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: CustomTextField(
                  icon: Image(
                    height: 10,
                    width: 10,
                    image: AssetImage(AppImages.cardicon),
                  ),
                  hinttext: 'Card Number',
                  controller: cardcontroller,
                ),
              ),
              Gap(height * 0.020),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomTextField(
                    controller: cvvcontroller,
                    hinttext: 'CVV',
                    fieldwidth: widht * 0.45,
                    fieldheight: 50,
                  ),
                  CustomTextField(
                    controller: excontroller,
                    hinttext: 'Expiration',
                    fieldwidth: widht * 0.45,
                    fieldheight: 50,
                  ),
                ],
              ),

              Gap(height * 0.51),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(widht * 1, 50),
                    backgroundColor: Colors.green,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(14),
                    ),
                  ),

                  onPressed: () {
                    if (cardcontroller.text.isEmpty ||
                        cvvcontroller.text.isEmpty ||
                        excontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please Fill All Card Details")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You Purchesed Offer Successfully"),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Save Card",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Gap(15),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context);

        return false;
      },
    );
  }
}
