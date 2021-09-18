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
    return Container(
      width: 325.0,
      height: 70.0,
      color: Colors.transparent,
      decoration: new BoxDecoration(
          color: Color.fromRGBO(79, 79, 79, 100),
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(40.0),
            topRight: const Radius.circular(40.0),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            color: Colors.transparent,
            decoration: new BoxDecoration(
                color: Color.fromRGBO(130, 130, 130, 100),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0),
                )),
            child: Center(
              child: Text(widget.id.toString()),
            ),
          ),
          SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 24,
              color: Color.fromRGBO(242, 242, 242, 100),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
              onPressed: () {/* Write listener code here */},
              icon: Icon(
                Icons.edit,
                color: Colors.black,
              )),
          SizedBox(width: 16)
        ],
      ),
    );
  }
}
