import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget{
  final String address;

  AddressTag(this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(address),
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: Border.all(color: Theme.of(context).accentColor)),
    );
  }
}