import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiitexpense/model/menuItem.dart';
import 'package:jiitexpense/model/menuItemWithQuantity.dart';
import 'package:jiitexpense/model/order.dart';
import 'package:jiitexpense/services/menuItem/menuItem.dart';
import 'package:jiitexpense/services/wallet/wallet.dart';

class OrderService {
  Firestore firestore = Firestore.instance;
  String onGoingOrderPath = 'ongoingOrder';
  String pastOrderPath = 'previousOrder';


  checkOrder(String userId, List<MenuItem> menuItems, List<int> quantity, String canteenId, int walletBalance) {

    DateTime now = DateTime.now();
    List<MenuItemWithQuantity> items = List();
    int totalAmount = 0;
    int totalEstimatedTime = 0;
    for (var i = 0; i < menuItems.length; i++) {
      items.add(MenuItemWithQuantity(
          name: menuItems[i].name,
          availability: menuItems[i].availability,
          quantity: quantity[i],
          cost: menuItems[i].cost,
          waitingTime: menuItems[i].waitingTime
      ));
      totalAmount += menuItems[i].cost * quantity[i];
      totalEstimatedTime += menuItems[i].waitingTime * quantity[i];
    }
    Order order = Order(
        userId: userId,
        dateTime: now,
        items: items,
        totalAmount: totalAmount,
        totalEstimatedTime: totalEstimatedTime,
        canteenId: canteenId
    );
    return order;
  }

  placeOrder(Order order, int walletBalance, List<MenuItem> menuItemList) async {
    await _deductAmount(0, walletBalance, order.canteenId, order.userId);
      await _deductAvailableItem(order, menuItemList);
      return 'yes';
  }

  _deductAmount(int totalAmount, int walletBalance, String canteenId, String userId) async {
    await WalletService().updateAmount(walletBalance-totalAmount, canteenId, userId);
  }


  _deductAvailableItem(Order order, List<MenuItem> menuItemList) async {
    await MenuItemService().deductAvailability(order, menuItemList);
  }

  Stream<List<Order>> getOnGoingOrderList(String userId, String canteenId) {
    Stream<QuerySnapshot> stream = firestore.collection(onGoingOrderPath)
        .where('canteenId', isEqualTo: canteenId)
        .orderBy('dateTime', descending: true)
        .snapshots();
    return stream.map((qShot) => qShot.documents.map((doc) =>
      Order.fromMap(doc.data, doc.documentID)
    ).toList());
  }

  Stream<List<Order>> getPrevOrderList(String userId, String canteenId) {
    Stream<QuerySnapshot> stream = firestore.collection(pastOrderPath)
        .where('canteenId', isEqualTo: canteenId)
        .orderBy('dateTime', descending: true)
        .snapshots();
    return stream.map((qShot) => qShot.documents.map((doc) =>
        Order.fromMap(doc.data, doc.documentID)
    ).toList());
  }

  moveDoc(Order order) async {
    Order orderToUpdate= Order(items:order.items, totalAmount: order.totalAmount, totalEstimatedTime: order.totalEstimatedTime, userId: order.userId,dateTime: order.dateTime,canteenId: order.canteenId, uid: order.uid );
    await firestore.collection(pastOrderPath).document(order.uid).setData(orderToUpdate.toJson());
    await firestore.collection(onGoingOrderPath).document(order.uid).delete();
    return order.uid;
  }
}