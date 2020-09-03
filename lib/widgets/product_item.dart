import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/widgets/badge.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../providers/auth.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  var _isLoading = false;

  void toggleFav(Product product, ProductsProvider productsProvider, scaffold,
      String token, String userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await product.toggleFavorite(token, userId);

      productsProvider.fetchAndSetProducts().then((response) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final product = Provider.of<Product>(
      context,
      listen: false,
    );
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );

    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: _isLoading
              ? Center(child: LinearProgressIndicator())
              : Text(
                  product.title,
                  textAlign: TextAlign.center,
                ),
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () => toggleFav(product, productsProvider, scaffold,
                  authData.token, authData.userId),
            ),
          ),
          trailing: Consumer<Cart>(
            builder: (ctx, cart, consumerChild) => Badge(
              valueColor: Color.fromRGBO(255, 255, 255, 1),
              child: consumerChild,
              value: cart.productTotalQtyInCart(product.id) == null
                  ? '0'
                  : cart.productTotalQtyInCart(product.id).toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItem(
                  product.id,
                  product.price,
                  product.title,
                );
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added item to cart!'),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
