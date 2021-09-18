import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddNewNode extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color plusColor;
  final Color strokeColor;

  const AddNewNode(
      {this.width = 325.0,
      this.height = 65.0,
      this.backgroundColor = const Color.fromRGBO(224, 224, 224, 100),
      this.plusColor = const Color.fromRGBO(51, 51, 51, 100),
      this.strokeColor = const Color.fromRGBO(79, 79, 79, 100)});

  @override
  _AddNewNodeState createState() => _AddNewNodeState();
}

class _AddNewNodeState extends State<AddNewNode> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          print('adding...');
        },
        child: DottedBorder(
          dashPattern: [10, 8],
          strokeCap: StrokeCap.round,
          borderType: BorderType.RRect,
          radius: Radius.circular(10.0),
          color: widget.strokeColor,
          strokeWidth: 1,
          child: Expanded(
            // width: widget.width,
            // height: widget.height,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Center(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontSize: 48,
                    color: widget.plusColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
