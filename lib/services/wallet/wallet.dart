import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiitexpense/model/wallet.dart';

class WalletService {

  Firestore firestore = Firestore.instance;
  String dbPath = 'Wallet';
  int balance;

  Stream<Wallet>getWalletBalanceStream(String canteenId, String userId) {
    return firestore.collection(dbPath).document(userId).snapshots().map((item) {
      return Wallet(canteenId: canteenId, balance: item.data[canteenId]);
    });
  }

  updateAmount(int newAmount, String canteenId, String userId) async {
    await firestore.collection(dbPath).document(userId).setData({canteenId: newAmount});
  }

  proceedTopUp(int amount, String canteenId, String userId) async {
    await firestore.collection(dbPath).document(userId).updateData({canteenId: FieldValue.increment(amount)});
    return true;
  }

  sendMoney(String senderId, String receiverId, String canteenId, int amount) async {
    await firestore.collection(dbPath).document(receiverId).updateData({canteenId: FieldValue.increment(amount)});
  }

}