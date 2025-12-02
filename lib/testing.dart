import 'package:flutter/material.dart';

class TestingPro extends StatefulWidget {
  const TestingPro({super.key});

  @override
  State<TestingPro> createState() => _TestingProState();
}

class _TestingProState extends State<TestingPro>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.green,
            child: TabBar(
              controller: _controller,
              tabs: [
                Tab(text: "las"),
                Tab(text: "ars"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [Text("Pehla daba"), Text("2sra daba")],
            ),
          ),
        ],
      ),
    );
  }
}
