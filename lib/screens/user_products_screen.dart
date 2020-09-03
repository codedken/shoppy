import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_product_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_products_item.dart';

import '../providers/products_provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _onRefresh(context),
        builder: (ctx, dataSnapshot) =>
            dataSnapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _onRefresh(context),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, productData, _) => ListView.builder(
                        padding: EdgeInsets.only(top: 12.0),
                        itemCount: productData.items.length,
                        itemBuilder: (ctx, i) {
                          return Column(
                            children: [
                              UserProductsItem(
                                productData.items[i].id,
                                productData.items[i].title,
                                productData.items[i].imageUrl,
                              ),
                              Divider(
                                thickness: 1.0,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
