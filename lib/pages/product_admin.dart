import 'package:flutter/material.dart';
import './product_edit.dart';
import './product_list.dart';
import '../models/product.dart';

class ManageProductsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text('Choose'),
                  automaticallyImplyLeading: false,
                ),
                ListTile(
                  leading: Icon(Icons.shop),
                  title: Text('All Products'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                )
              ],
            ),
          ),
          appBar: AppBar(
            title: Text('Manage Products'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Create Product',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'My Products',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ProductEditPage(),
              ProductListPage(null, null, null)
            ],
          ),
        ));
  }
}
