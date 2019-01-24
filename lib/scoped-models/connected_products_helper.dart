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
  String
      _selProductId; // although these properties are private, they are accessible in the same file by other classes
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
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.telegraph.co.uk/content/dam/food-and-drink/2017/07/06/TELEMMGLPICT000133992337_trans_NvBQzQNjv4BqpVlberWd9EgFPZtcLiMQfyf2A9a6I9YchsjMeADBa08.jpeg?imwidth=450',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return httpClient
        .post(
            'https://flutter101-11945.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
            body: json.encode(productData))
        .then((httpClient.Response response) {
      if (!(response.statusCode == 200 && response.statusCode == 201)) {
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
    }).catchError((error) {
      // generic error handling
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    return httpClient
        .get(
            'https://flutter101-11945.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((httpClient.Response response) {
      _isLoading = false;
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
            userId: productData['userId']);
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
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

  void toggleProductFavoriteStatus() {
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
      [AuthMode mode = AuthMode.Login]) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    if (mode == AuthMode.Login) {
      return httpClient.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3o',
          body: json.encode(authData),
          headers: {
            'Content-Type': 'application/json'
          }).then((httpClient.Response response) {
        return _actAccordingToResponse(response, mode);
      });
    } else {
      return httpClient.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3o',
          body: json.encode(authData),
          headers: {
            'Content-Type': 'application/json'
          }).then((httpClient.Response response) {
        return _actAccordingToResponse(response, mode);
      });
    }
  }

  Map<String, dynamic> _actAccordingToResponse(
      httpClient.Response response, AuthMode mode) {
    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      _authenticatedUser = User(
          id: json.decode(response.body)['localId'],
          email: json.decode(response.body)['email'],
          token: json.decode(response.body)['idToken']);

      ////////// timeout stuff
      DateTime now = DateTime.now();
      DateTime expiryTime = now.add(Duration(
          seconds: int.parse(json.decode(response.body)['expiresIn'])));
      setAuthTimeOut(int.parse(json.decode(response.body)['expiresIn']));
      _userSubject.add(true);
      //////////
      getSharedPreference().then((SharedPreferences pref) {
        pref.setString('userId', json.decode(response.body)['localId']);
        pref.setString('userEmail', json.decode(response.body)['email']);
        pref.setString('userToken', json.decode(response.body)['idToken']);
        pref.setString('tokenExpiryTime', expiryTime.toIso8601String());
      });
      return {'status': true, 'message': 'Authentication Succeeded!'};
    } else if (json.decode(response.body)['error']['message'] == 'EMAIL_EXISTS')
      return {'status': false, 'message': 'The Email already exists!'};
    else if (json.decode(response.body)['error']['message'] ==
        'EMAIL_NOT_FOUND')
      return {'status': false, 'message': 'This Email does not exists!'};
    else if (json.decode(response.body)['error']['message'] ==
        'INVALID_PASSWORD')
      return {'status': false, 'message': 'Invalid Password!'};
    else
      return {'status': false, 'message': 'Something went wrong!'};
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
    getSharedPreference().then((SharedPreferences pref) {
      pref.clear();
    });
  }

  void setAuthTimeOut(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
      _userSubject.add(false); // we are not authenticated anymore
    });
  }
}

mixin UtilitiesHelper on ConnectedProductsHelper {
  bool isLoading() {
    return _isLoading;
  }
}
