import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final String price;

  PriceTag(this.price);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      child: Container(
          child: Text(
            '\$$price',
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: Theme.of(context).accentColor),
    );
  }
}
