import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Bead {
  int id;
  int slot;
  Bead({required this.id, this.slot = 0});
}

class AnimatedBeadsCounter extends StatefulWidget {
  final VoidCallback onLeftBeadTap; // counterplus()
  final VoidCallback onRightBeadTap; // countermin()
  final Color beadColor;

  const AnimatedBeadsCounter({
    super.key,
    required this.onLeftBeadTap,
    required this.onRightBeadTap,
    this.beadColor = Colors.black,
  });

  @override
  AnimatedBeadsCounterState createState() => AnimatedBeadsCounterState();
}

class AnimatedBeadsCounterState extends State<AnimatedBeadsCounter> {
  static const int beadsPerSide = 3;
  static const Duration moveDuration = Duration(milliseconds: 200);
  static const double baseBeadRadius = 27.0;

  late List<Bead> leftBeads;
  late List<Bead> rightBeads;

  int? movingBeadId;
  int movingTargetSlot = -1;
  int nextId = 100;

  @override
  void initState() {
    super.initState();
    leftBeads = [Bead(id: 0), Bead(id: 1), Bead(id: 2)];
    rightBeads = [Bead(id: 3), Bead(id: 4), Bead(id: 5)];
  }

  Path buildCurvePath(Size size) {
    final double topMargin = baseBeadRadius + 14;
    final double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    return Path()
      ..moveTo(
        0,
        kIsWeb
            ? isMobile
                  ? size.height * 0.5
                  : size.height * 0.3
            : size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.31,
        topMargin,
        size.width,
        topMargin + 10,
      );
  }

  List<Offset> computePositions(Size size) {
    final path = buildCurvePath(size);
    final pm = path.computeMetrics().first;
    final totalLength = pm.length;

    const double leftStart = 0.00;
    const double leftEnd = 0.31;
    const double rightStart = 0.69;
    const double rightEnd = 1.00;

    final List<Offset> offsets = [];

    // left 3 beads
    for (int i = 0; i < beadsPerSide; i++) {
      final t = leftStart + (leftEnd - leftStart) * (i / (beadsPerSide - 1));
      offsets.add(pm.getTangentForOffset(t * totalLength)!.position);
    }

    // right 3 beads
    for (int i = 0; i < beadsPerSide; i++) {
      final t = rightStart + (rightEnd - rightStart) * (i / (beadsPerSide - 1));
      offsets.add(pm.getTangentForOffset(t * totalLength)!.position);
    }

    return offsets;
  }

  void triggerLeftBeadTap() {
    if (movingBeadId != null || leftBeads.isEmpty) return;
    final bead = leftBeads.last;
    widget.onLeftBeadTap();
    moveBeadById(bead.id);
  }

  void triggerRightBeadTap() {
    if (movingBeadId != null || rightBeads.isEmpty) return;
    final bead = rightBeads.first;
    widget.onRightBeadTap();
    moveBeadById(bead.id);
  }

  void moveBeadById(int id) {
    if (movingBeadId != null) return;

    final leftIndex = leftBeads.indexWhere((b) => b.id == id);
    final rightIndex = rightBeads.indexWhere((b) => b.id == id);

    final isLeft = leftIndex >= 0;
    final isRight = rightIndex >= 0;
    if (!isLeft && !isRight) return;

    final targetSlot = isLeft ? 3 : 2;

    setState(() {
      movingBeadId = id;
      movingTargetSlot = targetSlot;
    });

    Future.delayed(moveDuration, () {
      setState(() {
        if (isLeft) {
          final bead = leftBeads.removeAt(leftIndex);
          rightBeads.insert(0, bead);
          if (rightBeads.length > beadsPerSide) rightBeads.removeLast();
          leftBeads.insert(0, Bead(id: nextId++));
          if (leftBeads.length > beadsPerSide)
            leftBeads = leftBeads.sublist(0, beadsPerSide);
        } else {
          final bead = rightBeads.removeAt(rightIndex);
          leftBeads.add(bead);
          if (leftBeads.length > beadsPerSide) leftBeads.removeAt(0);
          rightBeads.add(Bead(id: nextId++));
          if (rightBeads.length > beadsPerSide)
            rightBeads = rightBeads.sublist(0, beadsPerSide);
        }

        movingBeadId = null;
        movingTargetSlot = -1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double beadRadius = (width / 30).clamp(baseBeadRadius, 70.0);
    bool isMobile = width < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final offsets = computePositions(size);
        final allBeads = <Bead>{...leftBeads, ...rightBeads}.toList();

        int slotFor(Bead bead) {
          if (movingBeadId == bead.id) return movingTargetSlot;
          final leftIdx = leftBeads.indexWhere((b) => b.id == bead.id);
          if (leftIdx >= 0) return leftIdx;
          final rightIdx = rightBeads.indexWhere((b) => b.id == bead.id);
          if (rightIdx >= 0) return beadsPerSide + rightIdx;
          return 0;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            triggerLeftBeadTap(); // tap anywhere = left bead tap
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < 0) {
              triggerRightBeadTap(); // swipe left = decrement
            }
          },
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: CurveLinePainter(buildCurvePath),
              ),
              for (final bead in allBeads)
                AnimatedPositioned(
                  key: ValueKey(bead.id),
                  duration: moveDuration,
                  curve: Curves.easeInOut,
                  left: offsets[slotFor(bead)].dx - beadRadius,
                  top: offsets[slotFor(bead)].dy - beadRadius,
                  width: beadRadius * 2,
                  height: beadRadius * 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (movingBeadId != null) return;
                      final isLeft = leftBeads.any((b) => b.id == bead.id);
                      if (isLeft) {
                        triggerLeftBeadTap(); // +1
                      }
                      // right beads do nothing
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.beadColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
}

class CurveLinePainter extends CustomPainter {
  final Path Function(Size) pathBuilder;
  CurveLinePainter(this.pathBuilder);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(pathBuilder(size), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class Bead {
//   int id;
//   int slot;
//   Bead({required this.id, required this.slot});
// }

// class AnimatedBeadsCounter extends StatefulWidget {
//   final VoidCallback onLeftBeadTap;
//   final VoidCallback onRightBeadTap;
//   final Color beadColor;

//   const AnimatedBeadsCounter({
//     super.key,
//     required this.onLeftBeadTap,
//     required this.onRightBeadTap,
//     this.beadColor = Colors.black,
//   });

//   @override
//   AnimatedBeadsCounterState createState() => AnimatedBeadsCounterState();
// }

// class AnimatedBeadsCounterState extends State<AnimatedBeadsCounter> {
//   static const int beadsPerSide = 3;
//   static const double beadRadius = 27;
//   static const Duration moveDuration = Duration(milliseconds: 700);

//   late List<Bead> beads;
//   int? movingBeadId;
//   int nextId = 100;

//   @override
//   void initState() {
//     super.initState();
//     beads = List.generate(6, (i) => Bead(id: i, slot: i));
//   }

//   /// ✅ Shared curve definition for both beads & line
//   Path buildCurvePath(Size size) {
//     final double topMargin = beadRadius + 8; // safe margin
//     return Path()
//       ..moveTo(0, size.height * 0.50)
//       ..quadraticBezierTo(
//         size.width * 0.31,
//         topMargin,
//         size.width,
//         topMargin + -10,
//       );
//   }

//   List<Offset> computePositions(Size size) {
//     final path = buildCurvePath(size);

//     final metrics = path.computeMetrics().toList();
//     if (metrics.isEmpty) {
//       return List.generate(6, (i) => Offset(50 + i * 60, size.height * 0.5));
//     }

//     final pm = metrics.first;
//     final totalLength = pm.length;

//     const double leftStart = 0.00;
//     const double leftEnd = 0.31;
//     const double rightStart = 0.69;
//     const double rightEnd = 1.00;

//     final List<Offset> offsets = [];

//     for (int i = 0; i < beadsPerSide; i++) {
//       final t = leftStart + (leftEnd - leftStart) * (i / (beadsPerSide - 1));
//       final distance = (t * totalLength).clamp(0.0, totalLength);
//       final tangent = pm.getTangentForOffset(distance);
//       offsets.add(tangent?.position ?? const Offset(0, 0));
//     }
//     for (int i = 0; i < beadsPerSide; i++) {
//       final t = rightStart + (rightEnd - rightStart) * (i / (beadsPerSide - 1));
//       final distance = (t * totalLength).clamp(0.0, totalLength);
//       final tangent = pm.getTangentForOffset(distance);
//       offsets.add(tangent?.position ?? const Offset(0, 0));
//     }
//     return offsets;
//   }

//   /// ✅ Bead tap only animates, does not increment counter
//   void handleTap(Bead tapped) {
//     if (movingBeadId != null) return;
//     moveBead(tapped);
//   }

//   /// ✅ External triggers increment + move
//   void triggerRightBeadTap() {
//     if (movingBeadId != null) return;
//     final rightBead = beads.firstWhere(
//       (b) => b.slot >= beadsPerSide,
//       orElse: () => beads[beadsPerSide],
//     );
//     // widget.onRightBeadTap(); // No longer needed here as the parent tap/swipe handles it
//     handleTap(rightBead);
//   }

//   void triggerLeftBeadTap() {
//     if (movingBeadId != null) return;
//     final leftBead = beads.firstWhere(
//       (b) => b.slot < beadsPerSide,
//       orElse: () => beads[0],
//     );
//     // widget.onLeftBeadTap(); // No longer needed here as the parent tap/swipe handles it
//     handleTap(leftBead);
//   }

//   void moveBead(Bead tapped) {
//     if (tapped.slot < beadsPerSide) {
//       // move left bead → right side
//       final int targetIndex = beads.indexWhere(
//         (b) => b.slot >= beadsPerSide && b.slot < beadsPerSide * 2,
//       );
//       if (targetIndex == -1) return;

//       final int targetSlot = beads[targetIndex].slot;
//       final int targetId = beads[targetIndex].id;
//       final int tappedId = tapped.id;
//       final int tappedSlot = tapped.slot;

//       setState(() {
//         beads.removeWhere((b) => b.id == targetId);
//         beads.add(Bead(id: nextId++, slot: tappedSlot));
//         final int idx = beads.indexWhere((b) => b.id == tappedId);
//         if (idx != -1) {
//           beads[idx].slot = targetSlot;
//           movingBeadId = tappedId;
//         }
//       });
//     } else {
//       // move right bead → left side
//       final int targetIndex = beads.indexWhere((b) => b.slot < beadsPerSide);
//       if (targetIndex == -1) return;

//       final int targetSlot = beads[targetIndex].slot;
//       final int targetId = beads[targetIndex].id;
//       final int tappedId = tapped.id;
//       final int tappedSlot = tapped.slot;

//       setState(() {
//         beads.removeWhere((b) => b.id == targetId);
//         beads.add(Bead(id: nextId++, slot: tappedSlot));
//         final int idx = beads.indexWhere((b) => b.id == tappedId);
//         if (idx != -1) {
//           beads[idx].slot = targetSlot;
//           movingBeadId = tappedId;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;

//     // 🔧 Auto-scale bead size by screen width
//     final double beadRadius = (width / 30).clamp(27.0, 70.0);
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // final size = Size(constraints.maxWidth, height * 0.30);
//         final size = Size(constraints.maxWidth, constraints.maxHeight);

//         final offsets = computePositions(size);

//         return SizedBox(
//           width: size.width,
//           height: size.height,
//           child: Stack(
//             children: [
//               CustomPaint(
//                 size: size,
//                 painter: CurveLinePainter(buildCurvePath),
//               ),
//               for (final bead in beads)
//                 AnimatedPositioned(
//                   key: ValueKey(bead.id),
//                   duration: moveDuration,
//                   curve: Curves.easeInOut,
//                   left: offsets[bead.slot].dx - beadRadius,
//                   top: offsets[bead.slot].dy - beadRadius,
//                   width: beadRadius * 2,
//                   height: beadRadius * 2,
//                   onEnd: (bead.id == movingBeadId)
//                       ? () {
//                           setState(() {
//                             movingBeadId = null;
//                           });
//                         }
//                       : null,
//                   child: GestureDetector(
//                     behavior: HitTestBehavior.opaque,
//                     onTap: () {
//                       // ✅ Left side beads now increment + animate
//                       if (bead.slot < beadsPerSide) {
//                         widget.onLeftBeadTap(); // counterplus
//                         moveBead(bead); // animate across
//                         return;
//                       }

//                       // 🚫 Right side beads do nothing at all
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: widget.beadColor,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.15),
//                             blurRadius: 5,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// /// ✅ Painter uses same curve as beads
// class CurveLinePainter extends CustomPainter {
//   final Path Function(Size) pathBuilder;
//   CurveLinePainter(this.pathBuilder);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final path = pathBuilder(size);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

// // NOTE: The outer GestureDetector logic (which you provided in the prompt)
// // is correct for handling the counter and animation trigger simultaneously:

// /*
// */

// import 'package:flutter/material.dart';

// class Bead {
//   int id;
//   int slot;
//   Bead({required this.id, this.slot = 0});
// }

// class AnimatedBeadsCounter extends StatefulWidget {
//   final VoidCallback onLeftBeadTap; // counterplus()
//   final VoidCallback onRightBeadTap; // countermin()
//   final Color beadColor;

//   const AnimatedBeadsCounter({
//     super.key,
//     required this.onLeftBeadTap,
//     required this.onRightBeadTap,
//     this.beadColor = Colors.black,
//   });

//   @override
//   AnimatedBeadsCounterState createState() => AnimatedBeadsCounterState();
// }

// class AnimatedBeadsCounterState extends State<AnimatedBeadsCounter> {
//   static const int beadsPerSide = 3;
//   static const Duration moveDuration = Duration(milliseconds: 700);
//   static const double baseBeadRadius = 27.0;

//   late List<Bead> leftBeads;
//   late List<Bead> rightBeads;

//   int? movingBeadId;
//   int movingTargetSlot = -1;
//   int nextId = 100;

//   @override
//   void initState() {
//     super.initState();
//     leftBeads = [Bead(id: 0), Bead(id: 1), Bead(id: 2)];
//     rightBeads = [Bead(id: 3), Bead(id: 4), Bead(id: 5)];
//   }

//   Path buildCurvePath(Size size) {
//     final double topMargin = baseBeadRadius + 8;
//     return Path()
//       ..moveTo(0, size.height * 0.5)
//       ..quadraticBezierTo(
//         size.width * 0.31,
//         topMargin,
//         size.width,
//         topMargin - 10,
//       );
//   }

//   List<Offset> computePositions(Size size) {
//     final path = buildCurvePath(size);
//     final pm = path.computeMetrics().first;
//     final totalLength = pm.length;

//     const double leftStart = 0.00;
//     const double leftEnd = 0.31;
//     const double rightStart = 0.69;
//     const double rightEnd = 1.00;

//     final List<Offset> offsets = [];

//     // left 3 beads
//     for (int i = 0; i < beadsPerSide; i++) {
//       final t = leftStart + (leftEnd - leftStart) * (i / (beadsPerSide - 1));
//       offsets.add(pm.getTangentForOffset(t * totalLength)!.position);
//     }

//     // right 3 beads
//     for (int i = 0; i < beadsPerSide; i++) {
//       final t = rightStart + (rightEnd - rightStart) * (i / (beadsPerSide - 1));
//       offsets.add(pm.getTangentForOffset(t * totalLength)!.position);
//     }

//     return offsets;
//   }

//   // void triggerLeftBeadTap() {
//   //   if (movingBeadId != null || leftBeads.isEmpty) return; // ❌ ignore if moving
//   //   final bead = leftBeads.last;
//   //   widget.onLeftBeadTap(); // counter increment only once
//   //   moveBeadById(bead.id);
//   // }

//   // void triggerRightBeadTap() {
//   //   if (movingBeadId != null || rightBeads.isEmpty)
//   //     return; // ❌ ignore if moving
//   //   final bead = rightBeads.first;
//   //   widget.onRightBeadTap(); // decrement counter only once
//   //   moveBeadById(bead.id);
//   // }

//   void triggerLeftBeadTap() {
//     if (movingBeadId != null || leftBeads.isEmpty) return;
//     final bead = leftBeads.last;
//     widget.onLeftBeadTap(); // increment
//     moveBeadById(bead.id);
//   }

//   void triggerRightBeadTap() {
//     if (movingBeadId != null || rightBeads.isEmpty) return;
//     final bead = rightBeads.first;
//     widget.onRightBeadTap(); // decrement
//     moveBeadById(bead.id);
//   }

//   void moveBeadById(int id) {
//     if (movingBeadId != null) return;

//     final leftIndex = leftBeads.indexWhere((b) => b.id == id);
//     final rightIndex = rightBeads.indexWhere((b) => b.id == id);

//     final isLeft = leftIndex >= 0;
//     final isRight = rightIndex >= 0;
//     if (!isLeft && !isRight) return;

//     final targetSlot = isLeft ? 3 : 2;

//     setState(() {
//       movingBeadId = id;
//       movingTargetSlot = targetSlot;
//     });

//     Future.delayed(moveDuration, () {
//       setState(() {
//         if (isLeft) {
//           final bead = leftBeads.removeAt(leftIndex);
//           rightBeads.insert(0, bead);
//           if (rightBeads.length > beadsPerSide) rightBeads.removeLast();
//           leftBeads.insert(0, Bead(id: nextId++));
//           if (leftBeads.length > beadsPerSide)
//             leftBeads = leftBeads.sublist(0, beadsPerSide);
//         } else {
//           final bead = rightBeads.removeAt(rightIndex);
//           leftBeads.add(bead);
//           if (leftBeads.length > beadsPerSide) leftBeads.removeAt(0);
//           rightBeads.add(Bead(id: nextId++));
//           if (rightBeads.length > beadsPerSide)
//             rightBeads = rightBeads.sublist(0, beadsPerSide);
//         }

//         movingBeadId = null;
//         movingTargetSlot = -1;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;
//     final beadRadius = (width / 30).clamp(baseBeadRadius, 70.0);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final size = Size(constraints.maxWidth, constraints.maxHeight);
//         final offsets = computePositions(size);
//         final allBeads = <Bead>{...leftBeads, ...rightBeads}.toList();

//         int slotFor(Bead bead) {
//           if (movingBeadId == bead.id) return movingTargetSlot;
//           final leftIdx = leftBeads.indexWhere((b) => b.id == bead.id);
//           if (leftIdx >= 0) return leftIdx;
//           final rightIdx = rightBeads.indexWhere((b) => b.id == bead.id);
//           if (rightIdx >= 0) return beadsPerSide + rightIdx;
//           return 0;
//         }

//         return GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () {
//             // tap anywhere → left bead + counter
//             triggerLeftBeadTap();
//           },
//           onHorizontalDragEnd: (details) {
//             if (details.primaryVelocity != null) {
//               if (details.primaryVelocity! > 0) {
//                 // swipe right → left bead + counter
//                 triggerLeftBeadTap();
//               } else if (details.primaryVelocity! < 0) {
//                 // swipe left → right bead + countermin
//                 triggerRightBeadTap();
//               }
//             }
//           },
//           child: Stack(
//             children: [
//               CustomPaint(
//                 size: size,
//                 painter: CurveLinePainter(buildCurvePath),
//               ),
//               for (final bead in allBeads)
//                 AnimatedPositioned(
//                   key: ValueKey(bead.id),
//                   duration: moveDuration,
//                   curve: Curves.easeInOut,
//                   left: offsets[slotFor(bead)].dx - beadRadius,
//                   top: offsets[slotFor(bead)].dy - beadRadius,
//                   width: beadRadius * 2,
//                   height: beadRadius * 2,
//                   child: GestureDetector(
//                     behavior: HitTestBehavior.opaque,
//                     onTap: () {
//                       if (movingBeadId != null) return;
//                       final isLeft = leftBeads.any((b) => b.id == bead.id);
//                       if (isLeft) {
//                         // left bead → counter + animate
//                         triggerLeftBeadTap();
//                       }
//                       // right bead → do nothing
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: widget.beadColor,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.15),
//                             blurRadius: 5,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );

//       },
//     );
//   }
// }

// class CurveLinePainter extends CustomPainter {
//   final Path Function(Size) pathBuilder;
//   CurveLinePainter(this.pathBuilder);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//     canvas.drawPath(pathBuilder(size), paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
