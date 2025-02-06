import 'package:flutter/material.dart';

class CustomBottom extends StatefulWidget {
  final Widget? child;
  final double maxHeight;
  final double minHeight;
  const CustomBottom(
      {super.key,
      this.child,
      required this.maxHeight,
      required this.minHeight});

  @override
  CustomBottomState createState() => CustomBottomState();
}

class CustomBottomState extends State<CustomBottom>
    with TickerProviderStateMixin {
  late double minHeight;
  late double maxHeight;
  late Offset _offset;

  @override
  void initState() {
    minHeight = widget.minHeight;
    maxHeight = widget.maxHeight;
    _offset = Offset(0, widget.minHeight);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        double currentHeight = _offset.dy - details.delta.dy;
        _offset = Offset(0, currentHeight);
        if (details.delta.dy < widget.minHeight) {
          _offset = Offset(0, _offset.dy);
        } else if (details.delta.dy > widget.minHeight) {
          _offset = Offset(0, widget.maxHeight);
        }
        setState(() {});
      },
      onPanEnd: (details) {
        if (details.localPosition.dy > widget.minHeight) {
          _offset = Offset(0, widget.minHeight);
        }
        if (details.localPosition.dy < widget.minHeight) {
          _offset = Offset(0, widget.maxHeight);
        }
        setState(() {});
      },
      child: BottomSheet(
          onClosing: () {},
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          animationController: AnimationController(
              vsync: this, duration: const Duration(milliseconds: 1)),
          builder: (context) => Container(
                height: _offset.dy,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: widget.child!,
              )),
    );
  }
}
