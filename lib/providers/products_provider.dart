import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './auth.dart';

import '../models/http_exceptions.dart';

import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String authToken;
  String userId;

  void receiveToken(Auth auth) {
    authToken = auth.token;
    userId = auth.userId;
  }

  var _showFavorites = false;

  List<Product> get items {
    if (_showFavorites) {
      return _items.where((prod) => prod.isFavorite).toList();
    }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavorites = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorites = false;
  //   notifyListeners();
  // }

  Future<void> addItem(Product product) async {
    final url =
        'https://shoppy-14a04.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'creatorId': userId,
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
          },
        ),
      );
      var newProduct = Product(
        description: product.description,
        price: product.price,
        title: product.title,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : "";
    var url =
        'https://shoppy-14a04.firebaseio.com/products.json?auth=$authToken$filterString';
    try {
      final response = await http.get(url);
      var fetchedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> prod = [];

      if (fetchedData == null) {
        return;
      }
      url =
          'https://shoppy-14a04.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body);
      fetchedData.forEach((prodId, prodItem) {
        prod.add(Product(
          id: prodId,
          description: prodItem['description'],
          price: prodItem['price'],
          imageUrl: prodItem['imageUrl'],
          title: prodItem['title'],
          isFavorite: favData == null ? false : favData[prodId] ?? false,
        ));
      });
      _items = prod;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateItem(String id, Product product) async {
    var prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url =
        'https://shoppy-14a04.firebaseio.com/products/$id.json?auth=$authToken';
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    _items[prodIndex] = product;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final url =
        'https://shoppy-14a04.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpExceptions('An error occured!!');
    }
    existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
