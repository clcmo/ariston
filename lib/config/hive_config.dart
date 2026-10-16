import 'package:hive_flutter/hive_flutter.dart';

class HiveConfig {
  HiveConfig._();

  static const chatBoxName = 'chat_history';

  static Future<void> start() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(chatBoxName);
  }
}
