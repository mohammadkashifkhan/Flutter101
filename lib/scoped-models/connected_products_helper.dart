import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as httpClient;
import 'package:rxdart/subjects.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/authmode.dart';
import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProductsHelper on Model {
  List<Product> _products = [];
  String _selProductId; // although these properties are private, they are accessible in the same file by other classes
  User _authenticatedUser;
  bool _isLoading = false;

  Future<SharedPreferences> getSharedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}

mixin ProductsHelper on ConnectedProductsHelper {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
      'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final httpClient.Response response = await httpClient.post(
          'https://flutter101-11945.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    return httpClient
        .get(
            'https://flutter101-11945.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((httpClient.Response response) {
      final Map<String, dynamic> productListData = json.decode(response.body);
      List<Product> fetchedProductList = [];
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null ? false : (productData['wishlistUsers'] as Map<String, dynamic>)
                .containsKey(_authenticatedUser.id));
        fetchedProductList.add(product);
      });
      _products = onlyForUser ? fetchedProductList.where((Product product) {
        return product.userId == _authenticatedUser.id;
      }).toList() : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      // generic error handling
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  Product get selectedProduct {
    if (selectedProductIndex == -1) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> updatedData = {
      'title': title,
      'description': description,
      'image':
          'https://www.telegraph.co.uk/content/dam/food-and-drink/2017/07/06/TELEMMGLPICT000133992337_trans_NvBQzQNjv4BqpVlberWd9EgFPZtcLiMQfyf2A9a6I9YchsjMeADBa08.jpeg?imwidth=450',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.id
    };
    return httpClient
        .put(
            'https://flutter101-11945.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updatedData))
        .then((httpClient.Response response) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      // generic error handling
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deleteProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return httpClient
        .delete(
            'https://flutter101-11945.firebaseio.com/products/$deleteProductId.json?auth=${_authenticatedUser.token}')
        .then((httpClient.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      // generic error handling
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
    httpClient.Response response;
    if (newFavoriteStatus) {
      response = await httpClient.put(
          'https://flutter101-11945.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await httpClient.delete(
          'https://flutter101-11945.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorite: !newFavoriteStatus);
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    }
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserHelper on ConnectedProductsHelper {
  Timer _authTimer;
  PublishSubject<bool> _userSubject =
      PublishSubject(); // used rxdart subject here for emitting out that we are not authenticated anymore

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  User get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    httpClient.Response response;
    if (mode == AuthMode.Login) {
      response = await httpClient.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3o',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await httpClient.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3op',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeOut(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
      now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() {
    getSharedPreference().then((SharedPreferences pref) {
      if (pref.getString('userToken') != null) {
        var expiryTimeString = pref.getString('tokenExpiryTime');
        if (DateTime.parse(expiryTimeString).isBefore(DateTime.now())) {
          _authenticatedUser = null;
          return; // token time out else continue
        }
        _authenticatedUser = User(
            id: pref.getString('userId'),
            email: pref.getString('userEmail'),
            token: pref.getString('userToken'));
        _userSubject.add(true);
        setAuthTimeOut(DateTime.parse(expiryTimeString)
            .difference(DateTime.now())
            .inSeconds); // if token has'nt expired, set remaining time
        notifyListeners();
      }
    });
  }

  void logout() {
    _authTimer.cancel(); // in case of logout, timer is reset
    _authenticatedUser = null;
    _userSubject.add(false);
    getSharedPreference().then((SharedPreferences pref) {
      pref.clear();
    });
  }

  void setAuthTimeOut(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilitiesHelper on ConnectedProductsHelper {
  bool isLoading() {
    return _isLoading;
  }
}
