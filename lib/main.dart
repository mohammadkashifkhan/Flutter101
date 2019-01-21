import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/home.dart';
import './pages/product_details.dart';
import './pages/products_admin.dart';
import './scoped-models/main_helper.dart';
// import 'package:flutter/rendering.dart';


void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(Flutter101());
}

class Flutter101 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Flutter101State();
  }
}

class _Flutter101State extends State<Flutter101> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: MainModel(),
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            accentColor: Colors.tealAccent,
            buttonColor: Colors.teal),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => HomePage(),
          '/admin': (BuildContext context) => ProductsAdminPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) =>
                  ProductDetailsPage(index),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => HomePage());
        },
      ),
    );
  }
}
