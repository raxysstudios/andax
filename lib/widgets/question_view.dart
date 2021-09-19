import 'package:flutter/material.dart';

class QuestionView extends StatefulWidget {
  const QuestionView();

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  final List<String> _dropdownValues = [
    "Node №1",
    "Node №2",
    "Node №3",
    "Node №4",
    "Node №5"
  ]; //The list of values we want on the dropdown

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 25.0),
      child: GestureDetector(
        onTap: () {
          print("closing question");
        },
        child: Container(
          width: 250,
          height: 110,
          decoration: BoxDecoration(
              color: Color.fromRGBO(51, 51, 51, 100),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                child: Container(
                  width: 240,
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Type in question",
                        fillColor: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                child: Container(
                  width: 240,
                  height: 45,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: Colors.red,
                        style: BorderStyle.solid,
                        width: 0.80),
                  ),
                  child: DropdownButton(
                    items: _dropdownValues
                        .map((value) => DropdownMenuItem(
                              child: Text(value),
                              value: value,
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      print("choosing node");
                    },
                    isExpanded: false,
                    value: _dropdownValues.first,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
