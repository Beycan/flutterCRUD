import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter_app_products/ui/product_screen.dart';
import 'package:flutter_app_products/ui/product_information.dart';
import 'package:flutter_app_products/model/product.dart';

class ListViewProduct extends StatefulWidget {
  @override
  _ListViewProductState createState() => _ListViewProductState();
}

final productReference=FirebaseDatabase.instance.reference().child('product');

class _ListViewProductState extends State<ListViewProduct> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  List<Product> items;
  StreamSubscription<Event> _onProductAddSubscription;
  StreamSubscription<Event> _onProductChangedSubscription;


  @override
  void initState() {
    super.initState();
    items=new List();
    _onProductAddSubscription=productReference.onChildAdded.listen(_onProductAdded);
    _onProductChangedSubscription=productReference.onChildChanged.listen(_onProductUpdate);

  }

  @override
  void dispose() {
    super.dispose();
    _onProductAddSubscription.cancel();
    _onProductChangedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final _title_style=const TextStyle(fontSize: 18.0,color: Colors.blueAccent);
    final _subtitle_style=const TextStyle(fontSize: 12.0,color: Colors.blueGrey);

    return MaterialApp(
      title: 'Product DB',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Product information',style:TextStyle(color: Colors.blueGrey)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: ListView.builder(
            itemCount: items.length,
            padding: EdgeInsets.only(top: 12.0),
            itemBuilder: (context,position){
              return Column(
                children: <Widget>[
                  Divider(height: 7.0,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                            title: Text('${items[position].name}',
                            style:_title_style,
                            ),
                            subtitle:
                              Text('${items[position].description}',
                              style: _subtitle_style,
                              ),
                          leading: Column(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blueGrey,
                                radius: 17.0,
                                child: Text('${position+1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21.0
                                ),
                                ),
                              )
                            ],
                          ),
                          onTap: ()=>_editProduct(context, items[position]),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.delete,color: Colors.red,),
                          onPressed: ()=>_deleteProduct(context,items[position],position)
                      ),
                      IconButton(
                          icon: Icon(Icons.edit,color: Colors.blueAccent,),
//                          onPressed: ()=>_editProduct(context,items[position])
                          onPressed: ()=>_navigateToProductInformation(context,items[position]),
                      ),
                      
                    ],

                  ),

                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Colors.deepOrangeAccent,
          onPressed: ()=> _createNewProduct(context),
        ),
      ),
    );
  }

  void _onProductAdded(Event event){
    setState(() {
      items.add(new Product.fromSnapShot(event.snapshot));
    });
  }
  void _onProductUpdate(Event event){
    var oldProductValue=items.singleWhere((product)=>product.id==event.snapshot.key);
    setState(() {
      items[items.indexOf(oldProductValue)]=new Product.fromSnapShot(event.snapshot);
    });
  }

  void _deleteProduct(BuildContext context,Product product,int position)async{
    await productReference.child(product.id).remove().then((_){
      setState(() {
       items.removeAt(position);
      });
    });
  }
  void _navigateToProductInformation(BuildContext context, Product product) async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context)=>ProductScreen(product)),
    );
  }


  void _editProduct(BuildContext context, Product product) async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context)=>ProductInformation(product)),
    );
  }
  void _createNewProduct(BuildContext context) async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context)=>ProductScreen(Product(null,'','','','',''))),
    );
  }
}
