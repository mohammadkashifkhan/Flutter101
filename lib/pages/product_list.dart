import 'package:flutter/material.dart';
import 'package:flutter101/scoped_models/product_helper.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_edit.dart';

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ProductHelper>(
      builder: (BuildContext context, Widget child, ProductHelper model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.products[index].title),
              // should be unique
              direction: DismissDirection.endToStart,
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(index);
                  model.deleteProduct();
                }
              },
              background: Container(
                alignment: Alignment(0.8, 0),
                color: Colors.red,
                child: Icon(Icons.delete),
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          model.products[index].imgUri,
                        ),
                      ),
                      title: Text(model.products[index].title),
                      subtitle:
                          Text('\$${model.products[index].price.toString()}'),
                      trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            model.selectProduct(index);
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ProductEditPage();
                            }));
                          })),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.products.length,
        );
      },
    );
  }
}
