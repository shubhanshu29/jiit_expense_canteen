import 'package:flutter/material.dart';
import 'package:jiitexpense/Layouts/error/error.dart';
import 'package:jiitexpense/Layouts/loading.dart';
import 'package:jiitexpense/Layouts/order/placeOrder.dart';
import 'package:jiitexpense/model/menuItem.dart';
import 'package:jiitexpense/model/order.dart';
import 'package:jiitexpense/model/user.dart';
import 'package:jiitexpense/model/wallet.dart';
import 'package:jiitexpense/services/cart/cart.dart';
import 'package:jiitexpense/services/order/order.dart';
import 'package:jiitexpense/services/wallet/wallet.dart';
import 'package:provider/provider.dart';

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
  final List<MenuItem> menuItem;
  final CartBloc cart;
  final String canteenId;
  const Checkout({Key key, this.menuItem, this.cart, this.canteenId})
      : super(key: key);
}

class _CheckoutState extends State<Checkout> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Order order;
    return StreamBuilder<Wallet>(
        stream:
            WalletService().getWalletBalanceStream(widget.canteenId, user.uid),
        builder: (context, wallet) {
          if (wallet.hasError) {
            return Text('Error aconnecting Database');
          }
          if (!wallet.hasData) {
            return Loading();
          }
          order = getOrder(user, wallet);
          return Scaffold(
            appBar: AppBar(
                title: Text('Review Updation'), automaticallyImplyLeading: true),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'Here are your added Items',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Spacer(),
                      Spacer(),
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: widget.cart.getSize() == 0
                        ? Text('You need to add some items here')
                        : ListView.builder(
                            itemCount: widget.cart.getSize(),
                            itemBuilder: (context, index) {
                              int key = widget.cart.cart.keys.elementAt(index);
                              return Row(
                                children: <Widget>[
                                  Text(
                                    widget.menuItem[key].name,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Spacer(),
                                  Spacer(),
                                  Text(
                                    '${widget.cart.cart[key]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Loading()));
                          String id = await OrderService().placeOrder(
                              order, wallet.data.balance, widget.menuItem);
                          Navigator.pop(context);
                          if (id == '') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ErrorScreenDisplay(
                                          errorMessage:
                                              'Unable to place order at given time',
                                        )));
                          } else {
                            order.uid = id;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PlaceOrder(
                                          order: order,
                                          isOnGoingOrder: true,
                                        )));
                          }
                        },
                        child: Text('Update availability'),
                        color: Colors.blue,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Order getOrder(User user, AsyncSnapshot<Wallet> wallet) {
    List<MenuItem> menuItems = List();
    List<int> quantityList = List();
    widget.cart.cart.forEach((menuItemIndex, quantity) {
      menuItems.add(widget.menuItem[menuItemIndex]);
      quantityList.add(quantity);
    });
    return OrderService().checkOrder(user.uid, menuItems, quantityList,
        widget.canteenId, wallet.data.balance);
  }
}
