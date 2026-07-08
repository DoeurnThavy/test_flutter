import 'package:flutter/material.dart';
import 'package:flutter_connection_api/models/product/Products.dart';

class ProductDetail extends StatelessWidget {
  Products product;

  ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title!)),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Image.network(product.thumbnail!),

            SizedBox(height: 20),

            Text(
              product.title!,

              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text("Price : \$${product.price}"),

            Text("Discount : ${product.discountPercentage}%"),

            SizedBox(height: 20),

            Text(product.description!),
          ],
        ),
      ),
    );
  }
}
