import 'package:connectivity/connectivity.dart';

class Utils {
  static Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
