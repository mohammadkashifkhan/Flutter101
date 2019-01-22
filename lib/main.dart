import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './models/product.dart';
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
    MainModel model= MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            secondaryHeaderColor: Colors.blue,
            accentColor: Colors.teal,
            buttonColor: Colors.blue),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => HomePage(model),
          '/admin': (BuildContext context) => ProductsAdminPage(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = model.allProducts.firstWhere((Product product){
              return product.id == productId;
            });

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) =>
                  ProductDetailsPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => HomePage(model));
        },
      ),
    );
  }
}
