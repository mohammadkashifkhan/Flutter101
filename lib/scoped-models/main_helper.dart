import 'package:scoped_model/scoped_model.dart';

import './connected_products_helper.dart';

class MainModel extends Model
    with ConnectedProductsHelper, UserHelper, ProductsHelper, UtilitiesHelper {
  // with actually helps in importing the properties from the specified classes
  // we did that because in the Main.dart file we can only specify only one Scoped Model
  // so to use the UserHelper, we have to make a ParentHelper which uses both these helpers
}
