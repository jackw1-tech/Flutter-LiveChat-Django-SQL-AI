import 'dart:io';

class Apicontants {
  static String get baseApiUrl {
    if (Platform.isAndroid) {
      // Android emulator loopback -> host machine
      return 'http://10.0.2.2:8000/api';
    }
    // iOS simulator and macOS share the host loopback
    return 'http://127.0.0.1:8000/api';
  }
}
