import 'package:flutter/material.dart';
import 'package:flutter101/scoped_models/main_helper.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/home.dart';
import './pages/product_admin.dart';
import './pages/product_details.dart';

void main() => runApp(Flutter101());

class Flutter101 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Flutter101State();
  }
}

class Flutter101State extends State<Flutter101> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainHelper>(
      model: MainHelper(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          buttonColor: Colors.deepPurple,
        ),
//      home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/admin': (BuildContext context) => ManageProductsPage(),
          '/home': (BuildContext context) => HomePage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') return null;
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductDetailsPage(index));
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
