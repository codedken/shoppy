import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './auth.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String authToken;
  String userId;

  void receiveToken(Auth auth) {
    authToken = auth.token;
    userId = auth.userId;
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shoppy-14a04.firebaseio.com/orders/$userId.json?auth=$authToken';
    List<OrderItem> loadedItems = [];
    final response = await http.get(url);
    var fetchedData = json.decode(response.body) as Map<String, dynamic>;
    if (fetchedData == null) {
      return;
    }
    fetchedData.forEach((orderId, orderData) {
      loadedItems.add(
        OrderItem(
          amount: orderData['amount'],
          datetime: DateTime.parse(orderData['datetime']),
          id: orderId,
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList(),
        ),
      );
    });

    _orders = loadedItems;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double totalAmount) async {
    final url =
        'https://shoppy-14a04.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode(
        {
          'creatorId': userId,
          'amount': totalAmount,
          'datetime': timestamp.toIso8601String(),
          'products': cartProducts
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                },
              )
              .toList(),
        },
      ),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: totalAmount,
        products: cartProducts,
        datetime: timestamp,
      ),
    );
    notifyListeners();
  }
}
