import 'package:flutter/material.dart';

class SearchAhadees extends StatefulWidget {
  const SearchAhadees({super.key});

  @override
  State<SearchAhadees> createState() => _SearchAhadeesState();
}

class _SearchAhadeesState extends State<SearchAhadees> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Search Ahadees")));
  }
}
