import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductHelper extends Model {
  List<Product> _products = [];
  int _selectedIndex;

  List<Product> get products {
    return List.from(_products);
  }

  int get selectedIndex {
    return _selectedIndex;
  }

  Product get selectedProduct{
    if(_selectedIndex==null) {
      return null;
    }
    return products[_selectedIndex];
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedIndex = null;
  }

  void updateProduct(Product product) {
    _products[_selectedIndex] = product;
    _selectedIndex = null;
  }

  void deleteProduct() {
    _products.removeAt(_selectedIndex);
    _selectedIndex = null;
  }

  void selectProduct(int index) {
    _selectedIndex = index;
  }
}
