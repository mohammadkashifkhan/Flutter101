import 'package:flutter/material.dart';

import '../widgets/ui_elements/title_default.dart';

import '../widgets/products/address_tag.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:flutter101/scoped_models/product_helper.dart';
import '../models/product.dart';

class ProductDetailsPage extends StatelessWidget {
  final int index;

  ProductDetailsPage(this.index);

  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you Sure?'),
            content: Text('This cant be undone!'),
            actions: <Widget>[
              RaisedButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
              RaisedButton(
                  child: Text('Discard'),
                  onPressed: () => Navigator.pop(context))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<ProductHelper>(
          builder: (BuildContext context, Widget child, ProductHelper model) {
        final Product product = model.products[index];
        return Scaffold(
          appBar: AppBar(title: Text(product.title)),
          body: Column(
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
                    DecoratedBox(
                      child: Container(
                          child: Text(
                            '\$${product.price}',
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 5.0)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Theme.of(context).accentColor),
                    )
                  ],
                ),
              ),
              AddressTag('Jumeirah Beach, Dubai'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                margin: EdgeInsets.only(top: 10.0),
                child: Text(
                  product.desc,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
