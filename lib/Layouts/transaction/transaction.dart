import 'package:flutter/material.dart';
import 'package:jiitexpense/Layouts/transaction/sendMoney.dart';
import 'package:jiitexpense/services/wallet/wallet.dart';

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
  final String canteenId;
  const Transaction({Key key, this.canteenId}): super(key: key);
}

class _TransactionState extends State<Transaction> {
  @override
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String id = '';
  int amount=0;
  String error='';
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet TopUp'),
      ),

      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 50.0),
              Text('Enter userID:'),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter correct user id';
                  }
                  id=value;
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Text('Enter amount:'),
              TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty || int.parse(value) <= 0) {
                    return 'Please enter correct amount';
                  }
                  amount=int.parse(value);
                  return null;
                },
              ),
              SizedBox(height: 50.0),
              RaisedButton(
                child: Text('Top Up'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await WalletService().proceedTopUp(amount,widget.canteenId,id);
                    if (result ) {
                      setState(() {
                        loading = false;
                        error = 'Successfully Recharged!!';
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              SizedBox(height: 12.0),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendMoney())
                  );
                },
                child: Text('Use QR code instead'),
              ),
              SizedBox(height: 12.0),
              Center(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.green[400],
                  ),
                ),
              ),
            ],
          ),
        ),





        /*Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SizedBox(height: 30,),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReceiveMoney(canteenId: widget.canteenId,))
                );
              },
              child: Text('Recieve'),
            ),
          ],
        ),*/
      ),
    );
  }
}
