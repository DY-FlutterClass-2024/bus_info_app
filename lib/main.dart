import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home_screen.dart';
import './screens/nearby_station_screen.dart';
import './screens/manage_shc_screen.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Common AppBar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/nearByStation': (context) => NearbyStationScreen(),
        '/manageShc': (context) => ManageShcScreen(),
      },
    );
  }
}
