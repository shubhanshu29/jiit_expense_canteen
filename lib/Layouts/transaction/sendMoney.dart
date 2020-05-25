import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:jiitexpense/model/user.dart';
import 'package:jiitexpense/model/wallet.dart';
import 'package:jiitexpense/services/wallet/wallet.dart';
import 'package:jiitexpense/shared/constants/text_input_decoration.dart';
import 'package:provider/provider.dart';
import '../loading.dart';

class SendMoney extends StatefulWidget {
  @override
  _SendMoneyState createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  String barcode = "";
  String error = "";
  int amount=0;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if (this.barcode == "") {
      return Scaffold(
        appBar: AppBar(
          title: Text('Scan to send money'),
        ),
        body: RaisedButton(
          onPressed: scan,
          child: Text('Scan'),
        ),
      );
    } else {
      String userId = barcode.split("__")[0];
      String canteenId = barcode.split("__")[1];
      return Scaffold(
        appBar: AppBar(
          title: Text('Scanned Result'),
        ),
        body: Column(
                children: <Widget>[
                  Text(userId),
                  Text(canteenId),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: TextFormField(
                        decoration:
                        textInputDecoration.copyWith(hintText: '1000 Rs.'),
                        onChanged: (val) {
                          amount= int.parse(val);
                        }),
                  ),
                  RaisedButton(
                    child: Text('Send'),
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Loading()));
                      await WalletService().sendMoney(user.uid, userId, canteenId, amount);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  Text('$error',
                    style: TextStyle(color: Colors.red),)
                ],
              ),

      );
    }
  }

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcode = barcode.rawContent;
      });
    } on PlatformException catch(e) {
      setState(() {
        this.barcode = e.message;
      });
      }
    }
}


