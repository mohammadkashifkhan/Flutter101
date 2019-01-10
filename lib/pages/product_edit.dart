import 'package:flutter/material.dart';

import '../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter101/scoped_models/product_helper.dart';

class ProductEditPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  Map<String, dynamic> _formData = {
    'title': null,
    'desc': null,
    'price': null,
    'imgUri': 'assets/food.jpg'
  };
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Widget _buildSubmitButton(){
    return ScopedModelDescendant<ProductHelper>(builder: (BuildContext context, Widget child, ProductHelper model){
      return RaisedButton(
        child: Text('Save'),
        textColor: Colors.white,
        onPressed: () {
          if (!formKey.currentState.validate()) {
            return;
          }
          formKey.currentState.save();

          widget.product == null ? model.addProduct(
              Product(title: _formData['title'], desc: _formData['desc'], imgUri: _formData['imgUri'], price: _formData['price']))
              : model.updateProduct(widget.productIndex, Product(title: _formData['title'], desc: _formData['desc'], imgUri: _formData['imgUri'], price: _formData['price']));

          Navigator.pushReplacementNamed(context, '/home');
        },
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.9;
    double targetPadding = deviceWidth - targetWidth;
    final Widget pageContent = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(
            FocusNode()); // to close the keyboard by tapping elsewhere
      },
      child: Container(
        width: targetWidth,
        margin: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              TextFormField(
                initialValue:
                    widget.product == null ? '' : widget.product.title,
                validator: (String value) {
                  if (value.isEmpty || value.length < 5)
                    return 'Title is required & should have 5+ characters';
                },
                decoration: InputDecoration(labelText: 'Title'),
                keyboardType: TextInputType.text,
                onSaved: (String value) {
                  _formData['title'] = value;
                },
              ),
              TextFormField(
                initialValue: widget.product == null ? '' : widget.product.desc,
                validator: (String value) {
                  if (value.isEmpty || value.length < 10)
                    return 'Description is required & should have 10+ characters';
                },
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.text,
                maxLines: 2,
                onSaved: (String value) {
                  _formData['desc'] = value;
                },
              ),
              TextFormField(
                initialValue: widget.product == null
                    ? ''
                    : widget.product.price.toString(),
                validator: (String value) {
                  if (value.isEmpty)
                    return 'Price is required & should be a number';
                },
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  _formData['price'] = double.parse(value);
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
    return widget.product == null
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Product'),
            ),
            body: pageContent,
          );
  }
}
