import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

mixin ProductHelper on Model { // mixins are normal classes from which we can borrow methods(or variables) without extending the class
  List<Product> _products = [];
  int _selectedIndex;
  bool _showFavorites = false;

  List<Product> get products {
    return List.from(_products);
  }

  List<Product> get favoriteProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(_products);
  }

  int get selectedIndex {
    return _selectedIndex;
  }

  Product get selectedProduct {
    if (_selectedIndex == null) {
      return null;
    }
    return products[_selectedIndex];
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedIndex = null;
    notifyListeners();
  }

  void toggleProductToFavorite() {
    updateProduct(Product(
        title: selectedProduct.title,
        desc: selectedProduct.desc,
        imgUri: selectedProduct.imgUri,
        price: selectedProduct.price,
        isFavorite: !_products[_selectedIndex].isFavorite));
    notifyListeners(); // is a method provided by scoped model to update the surrounded block of descendant to update, in this case where this method is called
  }

  void updateProduct(Product product) {
    _products[_selectedIndex] = product;
    _selectedIndex = null;
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selectedIndex);
    _selectedIndex = null;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleFavoriteOnHome() {
    _showFavorites = !_showFavorites;
    notifyListeners();
    _selectedIndex = null;
  }

  bool get isShowingFavorites {
    return _showFavorites;
  }
}
