import 'package:andax/widgets/add_new_question.dart';
import 'package:andax/widgets/question_preview.dart';
import 'package:flutter/material.dart';
import 'package:andax/widgets/question_view.dart';

class NodeView extends StatefulWidget {
  const NodeView({Key? key}) : super(key: key);

  @override
  _NodeViewState createState() => _NodeViewState();
}

class _NodeViewState extends State<NodeView> {
  final List<String> _dropdownValues = [
    "End Node",
    "Null",
  ]; //The list of values we want on the dropdown

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: 300,
        height: 450,
        decoration: BoxDecoration(
            color: Color.fromRGBO(79, 79, 79, 100),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Container(
                width: 300,
                height: 120,
                child: TextField(
                  maxLines: 5,
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              child: Container(
                width: 300,
                height: 230,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    QuestionView(),
                    QuestionPreview(text: "Hello my friend", id: 2),
                    AddNewQuestion(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 2.0),
                    child: Container(
                      width: 170,
                      height: 50,
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
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(130, 130, 130, 100),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: IconButton(
                        onPressed: () {
                          print('deleting...');
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black,
                        )),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(130, 130, 130, 100),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: IconButton(
                        onPressed: () {
                          print('saving...');
                        },
                        icon: Icon(
                          Icons.check,
                          color: Colors.black,
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
