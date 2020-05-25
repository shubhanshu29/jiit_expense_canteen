import 'package:flutter/material.dart';
import 'package:jiitexpense/Layouts/loading.dart';
import 'package:jiitexpense/Layouts/wallet/onGoingOrder.dart';
import 'package:jiitexpense/Layouts/wallet/prevOrder.dart';
import 'package:jiitexpense/model/user.dart';
import 'package:jiitexpense/model/wallet.dart';
import 'package:jiitexpense/services/wallet/wallet.dart';
import 'package:provider/provider.dart';


class WalletLayout extends StatefulWidget {
  @override
  _WalletLayoutState createState() => _WalletLayoutState();
  final String canteenId;
  const WalletLayout({Key key, this.canteenId}): super(key: key);
}

class _WalletLayoutState extends State<WalletLayout> {


  bool onGoingOrder = true;
  @override
  Widget build(BuildContext context) {

    User user = Provider.of<User>(context);

    Widget showOrders() {
      if (onGoingOrder) {
        return OnGoingOrders(user: user, widget: widget,);
      }
      return PrevOrder(user: user, widget: widget,);
    }
    Widget showChangeButton() {
      if (onGoingOrder) {
        return RaisedButton(
          child: Text('Previous Orders'),
          onPressed: () {
            setState(() {
              this.onGoingOrder = !this.onGoingOrder;
            });
          },
        );
      }
      return RaisedButton(
        child: Text('Current Orders'),
        onPressed: () {
          setState(() {
            this.onGoingOrder = !this.onGoingOrder;
          });
        },
      );
    }
    return StreamBuilder<Wallet>(
      stream: WalletService().getWalletBalanceStream(widget.canteenId, user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error Database connection');
        }
        if (!snapshot.hasData) {
          return Loading();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Orders'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 10,),

                  ],
                ),
                SizedBox(height: 30,),

                showChangeButton(),
                SizedBox(height: 20,),
                showOrders(),
              ],
            ),
          ),
        );
      }
    );
  }
}