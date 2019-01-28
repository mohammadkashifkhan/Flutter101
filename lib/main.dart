import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
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
  MapView.setApiKey('AIzaSyDQRXxzkCH0rCBQIBJC1iJgolmkZX_4_YQ');
  runApp(Flutter101());
}

class Flutter101 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Flutter101State();
  }
}

class _Flutter101State extends State<Flutter101> {
  MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated){ // will not execute immediately rather it will listen to the emitted subject
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
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
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(_model),
          '/admin': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          /////// only catches new navigation actions
          if(!_isAuthenticated){
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => AuthPage(),
            );
          }
          ///////
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductDetailsPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : HomePage(_model));
        },
      ),
    );
  }
}
