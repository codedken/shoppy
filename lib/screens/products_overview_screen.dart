import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';
import './cart_screen.dart';

enum FilterPage {
  favoriteProducts,
  allProducts,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isFav = false;
  var _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchAndSetProducts().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterPage selectedValue) {
              setState(() {
                if (selectedValue == FilterPage.allProducts) {
                  _isFav = false;
                }
                if (selectedValue == FilterPage.favoriteProducts) {
                  _isFav = true;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('All products'),
                  value: FilterPage.allProducts,
                ),
                PopupMenuItem(
                  child: Text('Favorite products'),
                  value: FilterPage.favoriteProducts,
                ),
              ];
            },
          ),
          Consumer<Cart>(
            builder: (ctx, cart, consumerChild) => Badge(
              child: consumerChild,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(_isFav),
    );
  }
}
