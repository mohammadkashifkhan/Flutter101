import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../models/product.dart';
import '../../scoped_models/main_helper.dart';

class Products extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainHelper>(builder: (BuildContext context, Widget child, MainHelper model){
      return _buildProductCard(model.favoriteProducts);
    },);
  }

  Widget _buildProductCard(List<Product> products){
    Widget productCard;
    if (products.length > 0) {
      productCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
        itemCount: products.length,
      );
    } else {
      productCard = Center(
        child: Text('No Data found'),
      );
    }
    return productCard;
  }
}
