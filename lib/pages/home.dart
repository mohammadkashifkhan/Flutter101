import 'package:flutter/material.dart';
import 'package:flutter101/scoped_models/main_helper.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/products/products.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text('Easy List'),
              automaticallyImplyLeading: false,
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.pushNamed(context, '/admin');
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Easy List'),
        actions: <Widget>[
          ScopedModelDescendant<MainHelper>(builder:
              (BuildContext context, Widget child, MainHelper model) {
            return IconButton(
              icon: Icon(model.isShowingFavorites == true
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                model.toggleFavoriteOnHome();
              },
            );
          })
        ],
      ),
      body: Products(),
    );
  }
}
