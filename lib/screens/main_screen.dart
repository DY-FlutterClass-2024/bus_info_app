import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './map_view_screen.dart';
import './nearby_station_screen.dart';
import './manage_shc_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _title = '지도화면';

  final List<Widget> _screens = [
    MapViewScreen(),
    NearbyStationScreen(),
    ManageShcScreen(),
  ];

  final List<String> _titles = [
    '지도화면',
    '주변정류소',
    '승하차관리',
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
      _title = _titles[index];
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1D1B20),
        iconTheme: IconThemeData(color: Colors.white), // Set the icon color to white
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF1D1B20),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1D1B20)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  children: [
                    Text('승하차알리미', style: TextStyle(color: Colors.white, fontSize: 24)),
                    Text('ver 1.0', style: TextStyle(color: Colors.white30, fontSize: 10)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('지도화면', style: TextStyle(color: Colors.white)),
              onTap: () => _navigateTo(0),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text('주변정류소', style: TextStyle(color: Colors.white)),
              onTap: () => _navigateTo(1),
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts, color: Colors.white),
              title: Text('승하차관리', style: TextStyle(color: Colors.white)),
              onTap: () => _navigateTo(2),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('설정', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text('앱 종료', style: TextStyle(color: Colors.white)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Color(0xFF1D1B20),
                      title: Text('앱 종료', style: TextStyle(color: Colors.white)),
                      content: Text('앱을 종료하시겠습니까?\n승하차알림이 종료됩니다.', style: TextStyle(color: Colors.white)),
                      actions: <Widget>[
                        TextButton(
                          child: Text('취소'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('확인'),
                          onPressed: () {
                            if (Platform.isAndroid) {
                              SystemNavigator.pop();
                            } else {
                              exit(0);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_currentIndex],
      ),
    );
  }
}