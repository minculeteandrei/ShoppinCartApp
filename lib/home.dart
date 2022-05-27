import 'dart:async';

import 'package:flutter/material.dart';
import 'package:l5_iot/UserModel.dart';
import 'package:l5_iot/product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'MyProfileScreen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textFieldNameController = TextEditingController();
  final TextEditingController textFieldQuantityController = TextEditingController();
  final TextEditingController textFieldPriceController = TextEditingController();
  final TextEditingController searchBarController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Product> shoppingCart = [];
  List<Product> duplicate = [];
  List<Product> favorites = [];
  List<Product> duplicateFavorites = [];
  int _selectedIndex = 0;
  String subtitle = "Products you have to buy";
  int count = 0;
  String userSurname = "";
  User user = FirebaseAuth.instance.currentUser!;
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    userModel = new UserModel(
        uid: user.uid,
        email: user.email.toString(),
        surname: userSurname,
        name: user.displayName.toString()
    );

  }


  void _onItemTapped(int index){
    if(index == 2)
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyProfileScreen())
      );
    else
      setState(() {
        if ((index == 0 && _selectedIndex == 1) || (index == 1 && _selectedIndex == 0)){
          List<Product> aux = shoppingCart;
          shoppingCart = favorites;
          favorites = aux;

          aux = duplicate;
          duplicate = duplicateFavorites;
          duplicateFavorites = aux;
          _selectedIndex = index;
        }
        if(index == 0)
          subtitle = "Products you have to buy";
        else if (index == 1)
          subtitle = "Favorites";
      });

  }

  @override
  Widget build(BuildContext context) {
    CollectionReference favItems = firestore.collection('favorites');

    Future<int> getAndUpdateId() async {
       var data = await favItems.doc("uniqueId").get();
      int id = int.parse(data["id"]);
      favItems.doc("uniqueId").update({'id': (id + 1).toString()});
      return id;
    }

    Future<int> addItem(String name, int qty, double price) async {
      int doc = await getAndUpdateId();
      favItems
          .doc(doc.toString())
          .set({
        'name': name,
        'quantity': qty,
        'price': price,
      })
          .then((value) => print("Item added"))
          .catchError((error) => print("Failed to add item to database: $error"));
      return doc;
    }

        Future<void> processSwipe(DismissDirection direction, int index) async {
      if(direction == DismissDirection.endToStart && _selectedIndex == 1)
        setState(() {
          favItems.doc(shoppingCart[index].dbId.toString())
              .delete()
              .then((value) => print("favorite deleted"))
              .catchError((error) => print("Failed to delete $error"));
          shoppingCart.removeAt(index);
        });
      else if(_selectedIndex == 1){
        setState(() {
          favorites.add(shoppingCart[index]);
          duplicateFavorites.add(shoppingCart[index]);
          shoppingCart.removeAt(index);
        });
      }
      else if(direction == DismissDirection.endToStart){
        setState(() {
          shoppingCart.removeAt(index);
        });
      }
      else {
        if(!shoppingCart[index].addedToDb){
          shoppingCart[index].dbId = await addItem(shoppingCart[index].name, shoppingCart[index].qty, shoppingCart[index].price) ;
          shoppingCart[index].addedToDb = true;
        }
        setState(() {
          favorites.add(shoppingCart[index]);
          duplicateFavorites.add(shoppingCart[index]);
          shoppingCart.removeAt(index);
        });
      }
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.title, textAlign: TextAlign.left,),
              OutlinedButton(
                  onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    primary: Colors.white
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.arrow_back),
                      Text("SignOut",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ],
                  )
              )
            ],
          )
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                children: [
                  Image.asset(
                    "assets/toDo.png",
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  onChanged: (value) {
                    searchItems(value);
                  },
                  controller: searchBarController,
                  decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all((Radius.circular(15.0)))
                      )
                  ),
                )
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: shoppingCart.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(shoppingCart[index].name),
                      onDismissed: (DismissDirection direction) {Future.wait([processSwipe(direction, index)]);},
                      child: ShoppingListItem(
                        product: shoppingCart[index],
                        inCart: shoppingCart.contains(shoppingCart[index]),
                        onCartChanged: onCartChanged,
                      ),
                      background: Container(
                        color: Colors.orange,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.star, color: Colors.black))),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.clear, color: Colors.black))),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Favorites'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
          ),
        ],
        selectedItemColor: Colors.amber,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(context),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void searchItems(String query){
    List<Product> searchList = [];
    searchList.addAll(duplicate);

    if(query.isNotEmpty){
      List<Product> listData = [];
      searchList.forEach((item) {
        if(item.name.contains(query))
          listData.add(item);
      });

      setState(() {
        shoppingCart.clear();
        shoppingCart.addAll(listData);
      });
      return;
    }
    else{
      setState(() {
        shoppingCart.clear();
        shoppingCart.addAll(duplicate);
      });
    }
  }

  Future displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Add a new product to your list",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: textFieldNameController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Quantity"),
                  controller: textFieldQuantityController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Price"),
                  controller: textFieldPriceController,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // print(textFieldController.text);
                  if (textFieldNameController.text.trim() != "" && textFieldQuantityController.text.trim() != "" && textFieldPriceController.text.trim() != "")
                    setState(() {
                      Product p = Product(
                          name: textFieldNameController.text,
                          qty: int.parse(textFieldQuantityController.text),
                          price: double.parse(textFieldPriceController.text));

                      shoppingCart.add(p);
                      duplicate.add(p);
                    });

                  textFieldNameController.clear();
                  textFieldQuantityController.clear();
                  textFieldPriceController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("save"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        });
  }

  void onCartChanged(Product product, bool inCart) {
    setState(() {
      // if (!inCart) shoppingCart.add(product);
      shoppingCart.remove(product);
    });
  }
}
