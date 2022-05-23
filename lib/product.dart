import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String name;
  final int qty;
  final double price;

  const Product({
    required this.name,
    required this.qty,
    required this.price,
  });
}

typedef void CartChangedCallback(Product product, bool inCart);

class ShoppingListItem extends StatelessWidget {
  final Product product;
  final inCart;
  final CartChangedCallback onCartChanged;

  ShoppingListItem({
    required this.product,
    @required this.inCart,
    required this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(product.name[0]),
      ),
      onTap: () => detailsDialog(context, product)
    );
  }
}

class WikiDescription{
  final String description;

  WikiDescription(this.description);

  factory WikiDescription.fromJson(Map<String, dynamic> json){
    var data = json['query']['pages'];
    var data2 = Map<String, dynamic>.from(data);
    var firstKey = data2.keys.toList()[0];
    if(data2[firstKey]['extract'].toString() == "null")
      return WikiDescription("No description...Sorry");

    return WikiDescription(data2[firstKey]['extract'].toString());
  }
}

Future<WikiDescription> fetchAlbum(String productName) async {
  final response = await http
      .get(Uri.parse('https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=' + productName));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WikiDescription.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}



Future detailsDialog(BuildContext context, Product product) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name + ":", textAlign: TextAlign.left,),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Quantity: " + product.qty.toString(), textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("Price: " + product.price.toString(), textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  child: FutureBuilder<WikiDescription>(
                    future: fetchAlbum(product.name),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!.description);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back"),
            )
          ],
        );
      }
  );
}
