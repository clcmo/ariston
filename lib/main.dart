import 'package:ariston/config/hive_config.dart';
import 'package:ariston/my_app.dart';
import 'package:ariston/services/auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        // ChangeNotifierProvider(create: (context) => ContaRepository()),
        // ChangeNotifierProvider(create: (context) => AppSettings()),
        // ChangeNotifierProvider(
        //   create: (context) => FavoritasRepository(
        //     auth: context.read<AuthService>(),
        //   ),
        // ),
      ],
      child: MyApp(),
    ),
  );
}
