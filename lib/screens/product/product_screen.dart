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
  int limit = 10;
  int skip = 0;
  int totalProducts = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts(isRefresh: true);
  }

  Future<void> _fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        isLoading = true;
        skip = 0;
        productList.clear();
      });
    }

    try {
      final uri = Uri.parse(
        "https://dummyjson.com/products?limit=$limit&skip=$skip",
      );

      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productResponse = ProductResponse.fromJson(data);

        setState(() {
          productList.addAll(productResponse.products ?? []);
          totalProducts = productResponse.total ?? 0;
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void _loadMoreProduct() {
    if (isLoading || isLoadingMore || productList.isEmpty) return;
    if (totalProducts > 0 && productList.length >= totalProducts) return;

    setState(() {
      isLoadingMore = true;
      skip += limit;
    });

    _fetchProducts();
  }

  List<Products> get filteredProducts {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      return productList;
    }
    return productList.where((product) {
      final title = product.title?.toLowerCase() ?? "";
      return title.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Products", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search loaded products...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (filteredProducts.isEmpty && !isLoading) {
      return const Center(child: Text("No products found"));
    }

    return RefreshIndicator(
      onRefresh: () => _fetchProducts(isRefresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
            _loadMoreProduct();
          }
          return true;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: filteredProducts.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filteredProducts.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final product = filteredProducts[index];
            return _buildProductCard(product);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Products product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetail(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product.thumbnail ?? "",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? "No Title",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.cyan[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${product.rating ?? 0.0}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
