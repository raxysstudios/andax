import 'package:flutter/material.dart';

class QuestionPreview extends StatefulWidget {
  final int id;
  final String text;
  const QuestionPreview({required this.text, required this.id});

  @override
  _QuestionPreview createState() => _QuestionPreview();
}

class _QuestionPreview extends State<QuestionPreview> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
      child: GestureDetector(
        onTap: () {
          print("Opening question");
        },
        child: Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: Color.fromRGBO(130, 130, 130, 100),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromRGBO(242, 242, 242, 100),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("Go to node");
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(79, 79, 79, 100),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Center(
                    child: Text(widget.id.toString()),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
