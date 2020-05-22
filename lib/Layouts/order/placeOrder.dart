import 'package:flutter/material.dart';
import 'package:jiitexpense/model/order.dart';
import 'package:jiitexpense/shared/widgets/timer.dart';

class PlaceOrder extends StatefulWidget {
  @override
  _PlaceOrderState createState() => _PlaceOrderState();
  final Order order;
  final bool isOnGoingOrder;
  const PlaceOrder({Key key, this.order, this.isOnGoingOrder}) : super(key: key);
}

class _PlaceOrderState extends State<PlaceOrder> {

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

    String heading = 'Here are your items that you wanted to add/remove';
    String status =  'Completed';
    String title = 'Menu updated successful';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
              children: <Widget>[
                Text(
                  '$heading',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                textWidgetHeading('Updation Status : $status'),
        ],
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
