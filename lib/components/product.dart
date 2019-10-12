import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:local_market/components/page.dart';
import 'package:local_market/components/product_details.dart';
import 'package:local_market/utils/utils.dart';
import 'package:local_market/views/product_view.dart';

class Product extends StatelessWidget {

  final Utils _utils = new Utils();

  var _product = null;

  Product(product){
    this._product = product;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
  child: Container(
    width: (MediaQuery.of(context).size.width / 2) - 40,
    // height: 110.0,
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 130,
              child: InkWell(
                onTap: (){
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => ProductView(
                    this._product
                  )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Image.network(
                      this._product['image'],
                      fit: BoxFit.cover,
                      // width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => ProductView(
                    this._product
                  )));
                },
                child: Text(
                  this._product['name'].length > 45 ? this._product['name'].substring(0, 45) + "..." : this._product['name'],
                  style: TextStyle(
                    fontSize: 15
                  ),
                    
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8.0, 0),
              child: Text('₹ ${this._product['price']}',
                style: TextStyle(
                  fontSize: 15
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0),
              child: ButtonTheme(
                minWidth: double.infinity,
                child: RaisedButton(
                  onPressed: (){

                  },
                  
                  color: _utils.colors['theme'],
                  child: Text(
                    "ADD",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _utils.colors['buttonText'],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            
          ],
        )
      ),
              
    );
  }
}