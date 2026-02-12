import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Search Haddes", style: TextStyle(fontSize: 20)),
          Text("حدیث تلاش کریں", style: TextStyle(fontSize: 20)),
          Gap(10),
          Row(children: [Expanded(child: TextField())]),
        ],
      ),
    );
  }
}
