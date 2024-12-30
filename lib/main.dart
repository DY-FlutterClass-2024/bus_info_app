import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/main_screen.dart';
import './screens/settings_screen.dart';
import './screens/settings/setting_notifications.dart';
import './screens/settings/setting_info.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawer Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/settings': (context) => SettingsScreen(),
        '/settings/nofications': (context) => SettingNotificationsScreen(),
        '/settings/info': (context) => SettingInfoScreen(),
      },
    );
  }
}