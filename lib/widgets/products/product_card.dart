import 'package:flutter/material.dart';
import 'package:flutter101/scoped_models/product_helper.dart';
import 'package:scoped_model/scoped_model.dart';

import './address_tag.dart';
import './price_tag.dart';
import '../../models/product.dart';
import '../ui_elements/title_default.dart';

class ProductCard extends StatelessWidget {
  Product product;
  int productIndex;

  ProductCard(this.product, this.productIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        Image.asset(product.imgUri),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitleDefault(product.title),
              SizedBox(
                width: 8.0,
              ),
              PriceTag(product.price.toString())
            ],
          ),
        ),
        AddressTag('Jumeirah Beach, Dubai'),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).accentColor,
                onPressed: () => Navigator.pushNamed(
                    context, '/product/' + productIndex.toString())),
            ScopedModelDescendant<ProductHelper>(builder:
                (BuildContext context, Widget child, ProductHelper model) {
              return IconButton(
                  icon: Icon(model.products[productIndex].isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () {
                    model.selectProduct(productIndex);
                    model.toggleProductToFavorite();
                  });
            })
          ],
        )
      ],
    ));
  }
}
