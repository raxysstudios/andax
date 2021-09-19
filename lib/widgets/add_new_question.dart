import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class AddNewQuestion extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color plusColor;
  final Color strokeColor;
  const AddNewQuestion(
      {this.width = 250.0,
      this.height = 50.0,
      this.backgroundColor = const Color.fromRGBO(189, 189, 189, 100),
      this.plusColor = const Color.fromRGBO(255, 255, 255, 100),
      this.strokeColor = const Color.fromRGBO(79, 79, 79, 100)});

  @override
  _AddNewQuestionState createState() => _AddNewQuestionState();
}

class _AddNewQuestionState extends State<AddNewQuestion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 25.0),
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
