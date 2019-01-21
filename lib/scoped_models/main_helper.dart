import 'package:scoped_model/scoped_model.dart';

import './product_helper.dart';
import './user_helper.dart';

class MainHelper extends Model with UserHelper, ProductHelper{ // with actually helps in importing the properties from the specified classes
                                                              // we did that because in the Main.dart file we can only specify only one Scoped Model
                                                              // so to use the UserHelper, we have to make a ParentHelper which uses both these helpers

}