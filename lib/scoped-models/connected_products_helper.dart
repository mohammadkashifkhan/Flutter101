import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as httpClient;
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProductsHelper on Model {
  List<Product> _products = [];
  String
      _selProductId; // although these properties are private, they are accessible in the same file by other classes
  User _authenticatedUser;
  bool _isLoading = false;
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
        .post('https://flutter101-11945.firebaseio.com/products.json',
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
        .get('https://flutter101-11945.firebaseio.com/products.json')
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
            'https://flutter101-11945.firebaseio.com/products/${selectedProduct.id}.json',
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
            'https://flutter101-11945.firebaseio.com/products/$deleteProductId.json')
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

  Future<Map<String, dynamic>> login(String email, String password) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    return httpClient.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3o',
        body: json.encode(authData),
        headers: {
          'Content-Type': 'application/json'
        }).then((httpClient.Response response) {
      print(json.decode(response.body));
      _isLoading = false;
      notifyListeners();
      if (response.statusCode == 200)
        return {'status': true, 'message': 'Authentication Succeeded!'};
      else if (json.decode(response.body)['error']['message'] ==
          'EMAIL_NOT_FOUND')
        return {'status': false, 'message': 'This Email does not exists!'};
      else if (json.decode(response.body)['error']['message'] ==
          'INVALID_PASSWORD')
        return {'status': false, 'message': 'Invalid Password!'};
      else
        return {'status': false, 'message': 'Something went wrong!'};
    });
    //    _authenticatedUser =
//        User(id: 'fdalsdfasf', email: email, password: password);
  }

  Future<Map<String, dynamic>> signUp(String email, String password) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    return httpClient.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC1ZjFvsdzibm7zaoKn0MU-H1HQSLPRq3o',
        body: json.encode(authData),
        headers: {
          'Content-Type': 'application/json'
        }).then((httpClient.Response response) {
      _isLoading = false;
      notifyListeners();
      if (response.statusCode == 200)
        return {'status': true, 'message': 'SignUp Succeeded!'};
      else if (json.decode(response.body)['error']['message'] == 'EMAIL_EXISTS')
        return {'status': false, 'message': 'The Email already exists!'};
      else
        return {'status': false, 'message': 'Something went wrong!'};
    });
  }
}

mixin UtilitiesHelper on ConnectedProductsHelper {
  bool isLoading() {
    return _isLoading;
  }
}
