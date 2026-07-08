import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_connection_api/models/product/Product_response.dart';
import 'package:flutter_connection_api/models/product/Products.dart';
import 'package:http/http.dart' as httpClient;

import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Products> productList = [];

  bool isLoading = false;

  bool isLoadingMore = false;

  int limit = 5;

  int skip = 0;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _getAllProduct();
  }
  // =========================
  // GET PRODUCT PAGINATION
  // =========================
  _getAllProduct() async {
    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse(
      "https://dummyjson.com/products?limit=$limit&skip=$skip",
    );

    var response = await httpClient.get(uri);

    var data = jsonDecode(response.body);

    var productResponse = ProductResponse.fromJson(data);

    await Future.delayed(Duration(seconds: 5));

    setState(() {
      productList.addAll(productResponse.products!);

      isLoading = false;
    });
  }
  // =========================
  // LOAD MORE
  // =========================

  _loadMoreProduct() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    skip += limit;

    await _getMoreProduct();
  }

  _getMoreProduct() async {
    var uri = Uri.parse(
      "https://dummyjson.com/products?limit=$limit&skip=$skip",
    );

    var response = await httpClient.get(uri);

    var data = jsonDecode(response.body);

    var productResponse = ProductResponse.fromJson(data);

    await Future.delayed(Duration(seconds: 5));

    setState(() {
      productList.addAll(productResponse.products!);

      isLoadingMore = false;
    });
  }

  // =========================
  // SEARCH
  // =========================

  List<Products> get searchProduct {
    if (searchController.text.isEmpty) {
      return productList;
    }

    return productList.where((product) {
      return product.title!.toLowerCase().contains(
        searchController.text.toLowerCase(),
      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,

        title: Text("Products", style: TextStyle(color: Colors.white)),
      ),

      body: Column(
        children: [
          // SEARCH BOX
          Padding(
            padding: EdgeInsets.all(10),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: "Search Product",

                prefixIcon: Icon(Icons.search),

                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels ==
                          scroll.metrics.maxScrollExtent) {
                        _loadMoreProduct();
                      }

                      return true;
                    },

                    child: ListView.builder(
                      itemCount: searchProduct.length + (isLoadingMore ? 1 : 0),

                      itemBuilder: (context, index) {
                        if (index == searchProduct.length) {
                          return Padding(
                            padding: EdgeInsets.all(20),

                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        var product = searchProduct[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetail(product: product),
                              ),
                            );
                          },

                          child: Container(
                            margin: EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.black12,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Column(
                              children: [
                                Image.network(product.thumbnail!),

                                Padding(
                                  padding: EdgeInsets.all(10),

                                  child: Text(product.title!),
                                ),

                                Text("\$${product.price}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
