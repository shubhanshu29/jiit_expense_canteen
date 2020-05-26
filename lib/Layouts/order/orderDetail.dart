import 'package:flutter/material.dart';
import 'package:jiitexpense/model/order.dart';
import 'package:jiitexpense/services/order/order.dart';
import 'package:jiitexpense/shared/widgets/timer.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:jiitexpense/model/user.dart';
import 'package:jiitexpense/shared/constants/text_input_decoration.dart';
import 'package:provider/provider.dart';

class OrderDetail extends StatefulWidget {
  @override
  _OrderDetailState createState() => _OrderDetailState();
  final Order order;
  final bool isOnGoingOrder;
  const OrderDetail({Key key, this.order, this.isOnGoingOrder}) : super(key: key);
}

class _OrderDetailState extends State<OrderDetail> {

  textWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
      ),
      textAlign: TextAlign.center,
    );
  }
  textWidgetHeading(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
  @override
  Widget build(BuildContext context) {

    String heading = 'Order Items';
    String status =  'In Queue';
    String title = 'Order Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height : 25),
          Text(
            '$heading',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height : 25),
          TimeToOrder(
            totalDuration: widget.order.totalEstimatedTime,
            start: widget.order.dateTime,
          ),
          SizedBox(height: 20,),
          Expanded(
            child: Table(
              children: getOrderItems(),
            ),
          ),
          textWidgetHeading('Order Status : $status'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ScanToDeliver(order: widget.order)
              )
          );
        },
        child: Icon(Icons.center_focus_weak),
        backgroundColor: Colors.blue,
      ),
    );
  }

  getOrderItems() {
    List<TableRow> row = List();
    row.add(TableRow(
        children: [
          textWidgetHeading('Item'),
          textWidgetHeading('Quantity'),
        ]
    ));
    widget.order.items.forEach((val) => {
      row.add(TableRow( children : [
        textWidget('${val.name}'),
        textWidget('${val.quantity}'),
      ]))
    });
    return row;
  }
}

class ScanToDeliver extends StatefulWidget {
  @override
  _ScanToDeliverState createState() => _ScanToDeliverState();
  final Order order;
  const ScanToDeliver({Key key, this.order});
}

class _ScanToDeliverState extends State<ScanToDeliver> {
  String barcode = "";
  String error = "";
  int amount=0;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if (this.barcode == "") {
      return Scaffold(
        appBar: AppBar(
          title: Text('Scan to verify order'),
        ),
        body: RaisedButton(
          onPressed: scan,
          child: Text('Scan'),
        ),
      );
    } else {
      String orderId = barcode.split("__")[0];
      return Scaffold(
        appBar: AppBar(
          title: Text('Scanned Result'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Mark order as delivered'),
              onPressed: () async {
                if(orderId== widget.order.uid) {
                  await OrderService().moveDoc(widget.order);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
                else{
                  Text('The order doesn,t belong to this QR');
                }
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