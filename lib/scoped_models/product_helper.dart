import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductHelper extends Model {
  List<Product> _products = [];
  int _selectedIndex;

  List<Product> get products{
    return List.from(_products);
  }

  void addProduct(Product product) {
    _products.add(product);
  }

  void updateProduct(Product product) {
    _products[_selectedIndex] = product;
  }

  void deleteProduct() {
    _products.removeAt(_selectedIndex);
  }

  void selectProduct(int index){
    _selectedIndex =  index;
  }
}
