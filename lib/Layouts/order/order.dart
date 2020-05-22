import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:jiitexpense/Layouts/checkout/checkout.dart';
import 'package:jiitexpense/Layouts/loading.dart';
import 'package:jiitexpense/model/menuItem.dart';
import 'package:jiitexpense/model/menuItems.dart';
import 'package:jiitexpense/services/auth/auth.dart';
import 'package:jiitexpense/services/cart/cart.dart';
import 'package:jiitexpense/services/menuItem/menuItem.dart';
import 'package:jiitexpense/shared/widgets/menu_item.dart';
import 'package:provider/provider.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
  final String canteenId;
  const Order({Key key, this.canteenId}): super(key: key);
}

class _OrderState extends State<Order> {

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {

    var cartBloc = Provider.of<CartBloc>(context);
    int totalItemsInCart = cartBloc.getSize();

    var streamBuilder = StreamBuilder<MenuItems>(
      stream: MenuItemService().stream(widget.canteenId),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Text('Error Loading Database');
        }
          else if (!snapshot.hasData) {
            return Loading();
          }
          else {
            List<MenuItem> menuItems = snapshot.data.menuItems;
            return Scaffold(
              appBar: AppBar(
                title: Text('Menu Items'),
                actions: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Checkout(cart: cartBloc, menuItem: menuItems, canteenId: widget.canteenId,)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.4),
                      child: Badge(
                        badgeContent: Text('$totalItemsInCart'),
                        child: Icon(Icons.shopping_cart),
                        badgeColor: Colors.white,
                      ),
                    ),
                  ),

                  FlatButton(
                    child: Text('Logout'),
                    onPressed: () async {
                      await authService.signOut();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return MenuItemWidget(menuItem: menuItems[index], menuItemIndex: index, updateQuantity: cartBloc.addToCart,);
//                    return MenuItem(itemName: this.menuItems[index]);
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddItem(widget.canteenId)),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
              ),
            );
        }
      },
    );

    return streamBuilder;
  }

  updateQuantity(int selectedCanteenIndex, int menuItemIndex, int quantity) {

  }
}

class AddItem extends StatefulWidget {
  final String canteenId;

  @override
  _AddState createState() => _AddState();

  AddItem(this.canteenId);
}

class _AddState extends State<AddItem>{

  @override
  String nameOfItem='';
  int availability=0;
  final _formKey = GlobalKey<FormState>();
  int price=0;
  int waitingTime=0;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add menu item"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15.0),
            Text('Enter name of the item:'),
            TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                nameOfItem=value;
                return null;
              },
            ),
            SizedBox(height: 15.0),
            Text('Enter cost of the item:'),
            TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if(value.isEmpty || int.parse(value) < 0) {
                  return 'Please enter valid cost';
                }
                price=int.parse(value);
                return null;
              },
            ),
            SizedBox(height: 15.0),
            Text('Enter availability'),
            TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if(value.isEmpty || int.parse(value) < 0) {
                  return 'Please enter valid availability';
                }
                availability=int.parse(value);
                return null;
              },
            ),
            SizedBox(height: 15.0),
            Text('Enter approx waiting time in minutes: '),

            TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if(value.isEmpty || int.parse(value) < 0) {
                  return 'Please enter valid waiting time';
                }
                waitingTime=int.parse(value);
                return null;
              },
            ),
            SizedBox(height: 35.0),
            RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (_formKey.currentState.validate()) {
                  MenuItemService().addMenuItem(price, waitingTime, nameOfItem, availability , widget.canteenId);
                  Navigator.pop(context);
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0x87CEEB),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child:
                const Text('Add Item', style: TextStyle(fontSize: 20)),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
