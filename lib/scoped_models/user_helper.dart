import 'package:scoped_model/scoped_model.dart';

import '../models/user.dart';

mixin UserHelper on Model { // mixins are normal classes from which we can borrow methods(or variables) without extending the class
  User _authenticatedUser;

  void login(String email, String password){
    _authenticatedUser= User(id: 'dafadfadsf', email: email, password: password);
  }

}