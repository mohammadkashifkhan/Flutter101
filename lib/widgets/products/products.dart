import 'package:flutter/material.dart';

import './product_card.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped_models/product_helper.dart';
import '../../models/product.dart';

class Products extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ProductHelper>(builder: (BuildContext context, Widget child, ProductHelper model){
      return _buildProductCard(model.products);
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
