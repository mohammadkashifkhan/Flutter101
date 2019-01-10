import 'package:flutter/material.dart';
import './product_edit.dart';
import '../models/product.dart';

class ProductListPage extends StatelessWidget {
  final List<Product> products;
  final Function updateProduct, deleteProduct;

  ProductListPage(this.products, this.updateProduct, this.deleteProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(products[index].title),
          // should be unique
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              deleteProduct(index);
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
                    products[index].imgUri,
                  ),
                ),
                title: Text(products[index].title),
                subtitle: Text('\$${products[index].price.toString()}'),
                trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ProductEditPage(
                          product: products[index],
                          updateProduct: updateProduct,
                          productIndex: index,
                        );
                      }));
                    }),
              ),
              Divider()
            ],
          ),
        );
      },
      itemCount: products.length,
    );
  }
}
