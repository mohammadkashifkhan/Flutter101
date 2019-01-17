import 'package:flutter/material.dart';

class Product {
  final String title, desc, imgUri;
  final double price;
  final bool isFavorite;

  Product(
      {@required this.title,
      @required this.desc,
      @required this.imgUri,
      @required this.price,
      this.isFavorite=false});
}
