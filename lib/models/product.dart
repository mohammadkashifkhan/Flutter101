import 'package:flutter/material.dart';

class Product {
  final String title, desc, imgUri;
  final double price;

  Product(
      {@required this.title,
      @required this.desc,
      @required this.imgUri,
      @required this.price});
}
