import 'package:flutter/material.dart';

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
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {},
          )
        ],
      ),
      body: Products(),
    );
  }
}
