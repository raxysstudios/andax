import 'package:flutter/material.dart';

class NodePreview extends StatefulWidget {
  final int id;
  final String text;
  const NodePreview({required this.text, required this.id});

  @override
  _NodePreviewState createState() => _NodePreviewState();
}

class _NodePreviewState extends State<NodePreview> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        width: 325.0,
        height: 70.0,
        decoration: BoxDecoration(
            color: Color.fromRGBO(79, 79, 79, 100),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(130, 130, 130, 100),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Center(
                child: Text(widget.id.toString()),
              ),
            ),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(242, 242, 242, 100),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(130, 130, 130, 100),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: IconButton(
                  onPressed: () {
                    print('editing...');
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
