import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/page/home.dart';
import 'package:universal_html/html.dart' as html;

FirebaseOptions getOptions() {
  const appId = kIsWeb
      ? "1:288296082099:web:316d7ca65ff3eec717eec6"
      : "1:288296082099:web:316d7ca65ff3eec717eec6"; // Fix android
  return const FirebaseOptions(
      apiKey: "AIzaSyCbom6v21H-O0L1B0G7sqjKs92UDWjP4rQ",
      appId: appId,
      messagingSenderId: "288296082099",
      projectId: "game-hub-a86dd");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: getOptions());
  html.window.onBeforeUnload.listen((event) async {
    await GameManager.instance.leaveRoom();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}
