import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_market/components/app_bar.dart';
import 'package:local_market/components/circular_loading_button.dart';
import 'package:local_market/components/page.dart';
import 'package:local_market/controller/order_controller.dart';
import 'package:local_market/controller/user_controller.dart';
import 'package:local_market/utils/utils.dart';
import 'package:local_market/utils/globals.dart' as globals;
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:local_market/views/order_status.dart';

class Payment extends StatefulWidget {
  String name,phone, address, landmark;

  Payment(String name, String phone, String address, String landmark){
    this.name = name;
    this.phone = phone;
    this.address = address;
    this.landmark = landmark;
  }
  @override
  _PaymentState createState() => _PaymentState(this.name, this.phone, this.address, this.landmark);
}

class _PaymentState extends State<Payment> {

  String name, phone, address, landmark;
  final Utils _utils = new Utils();
  final OrderController _orderController = new OrderController();
  final UserController _userController = new UserController();
  Map<String, dynamic> cart = new Map<String, dynamic> ();
  double total = 0;
  _PaymentState(this.name, this.phone,this.address, this.landmark);
  bool _loading = false;
  int deliverCharge = 20;

  @override void initState() {
    super.initState();
    setState(() {
      this.cart= globals.cart;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Page(
      appBar: RegularAppBar(
        iconTheme: IconThemeData(
            color: _utils.colors['appBarIcons']
        ),
        backgroundColor: _utils.colors['appBar'],
        brightness: Brightness.light,
        elevation: _utils.elevation,
        title: Text("Payment",
          style: TextStyle(
            color: _utils.colors['appBarText'],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Material(
//            borderRadius: BorderRadius.circular(20.0),
            color: _utils.colors['theme'],
            // elevation: _utils.elevation,
            child: _loading ? CircularLoadingButton() :  MaterialButton(
              onPressed: () async {
//                validateAndUpdate();
                  // FirebaseUser _user = await UserController().getCurrentUser();
                  if(globals.currentUser != null){
                    setState(() {
                      _loading = true;
                    });
                    await _orderController.add(globals.cart, globals.total < 250 ? this.deliverCharge : 0, globals.currentUser.data['uid'], this.name, this.address, this.phone, this.landmark).then((orderId){
                      globals.cart = new Map<String, dynamic>();
                      globals.cartSize = 0;
                      globals.total = 0;
                      Navigator.pushReplacement(context, CupertinoPageRoute(builder:(context) => OrderStatus(orderId)));
                    }).catchError((e){
                      setState(() {
                        _loading = false;
                      });
                      print('Payment Page Error: ${e.toString()}');
                    });
                  }
              },
              minWidth: MediaQuery.of(context).size.width,
              child: Text(
                "Place Order",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _utils.colors['buttonText'],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      children: <Widget>[
//        PageItem(
//          child: Text("Hello"),
//        )
//        PageList(
//          children: <Widget>[
//            Text("Hello")
//          ],
//        )
        PageList(
          children : <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border :Border.all(color: Colors.grey)
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 8, 8),
                      child: Text("Delivery details: ",
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      title: Text(
                          this.name
                      ),
                      subtitle: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(this.phone),
                          Text(this.address),
                          Text(this.landmark)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )

          ]
        ),

        PageList.builder(
            itemCount: this.cart.length,
            itemBuilder: (context,i){
              // total += double.parse(this.cart[index]['discountedprice']);
              // total = 0;
              var keys = this.cart.keys.toList();
//            this.total += double.parse(this.cart[keys[i]]['data']['price']) * double.parse(this.cart[keys[i]]['count']);
              if(this.cart[keys[i]]['count'] != "0"){
                return product_instance_cart(this.cart[keys[i]]['data']["id"],
                  this.cart[keys[i]]['data']["image"],
                  this.cart[keys[i]]['data']["name"],
                  this.cart[keys[i]]['data']["price"],
                  this.cart[keys[i]]['data']["offerPrice"],
                  this.cart[keys[i]]['count'],
                  this.cart[keys[i]]['size']

                );
              }else return Container();
            }
        ),
        PageItem(

          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Items',style: TextStyle(fontSize: 16),),
                        Text('₹${globals.total.toString()}',style: TextStyle(fontSize: 16),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Delivery',style: TextStyle(fontSize: 16),),
                        Text('₹${this.deliverCharge}',style: TextStyle(fontSize: 16),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text('₹${(globals.total+this.deliverCharge)}'.toString(),style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                      ],
                    ),
                    globals.total < 250 ? Row() : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Promo(Free Delivery)',style: TextStyle(fontSize: 16),),
                        Text('-₹${this.deliverCharge}',style: TextStyle(fontSize: 16),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Order Total',
                          style: TextStyle(
                              fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text('₹${globals.total < 250 ? globals.total + this.deliverCharge : globals.total.toString()}',
                          style: TextStyle(
                              fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PageItem(
          child:Padding(
            padding: const EdgeInsets.all(12.0),
            child: globals.total < 250 ? Text(
                '* Free delivery above 249\n Add items worth ₹${250 - globals.total} or more to get free delivery',
              style: TextStyle(
                  color: _utils.colors['theme'],
                fontWeight: FontWeight.bold
              ),
            ) : Row(),
          )
        ),
        PageList(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 8, 15.0, 8),
              child: Text("Payment Options",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            ListTile(
              title: Text("Cash on delivery"),
              leading: new Radio(
                value: 0,
                groupValue: 0,
                activeColor: _utils.colors['theme'],
                onChanged: (value){

                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget product_instance_cart(prod_id,prod_image, prod_name, prod_price, prod_discountedprice,prod_count, prod_size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          leading: new Image.network(prod_image,
            width: 100.0,
            // height: 150.0,
            // fit: BoxFit.cover,
          ),
          title: new Text(
            prod_name.length > 30
                ? prod_name.substring(0, 30) + "..."
                : prod_name,
            style: TextStyle(fontSize: 15.0),),
          subtitle: new Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 0.0),
                    child: new Text("Offer Price:",
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 4.0, 8.0, 0.0),
                    child: new Text('Rs $prod_discountedprice',
                      style: TextStyle(color: Colors.green, fontSize: 13.0),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text("Price:",
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text('Rs $prod_price',
                      style: TextStyle(color: Colors.red, fontSize: 13.0),
                    ),
                  ),
                ],
              ),
              prod_size != null ? Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text("Size:",
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text('₹$prod_size',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13.0),
                    ),
                  ),
                ],
              ) : Container(),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text("Quantity:",
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new Text('$prod_count',
                      style: TextStyle( fontSize: 13.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
