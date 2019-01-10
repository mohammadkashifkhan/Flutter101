import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  String title;

  TitleDefault(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 26.0, fontFamily: 'Oswald', fontWeight: FontWeight.bold),
    );
  }
}
