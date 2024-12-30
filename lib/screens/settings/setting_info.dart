import 'package:flutter/material.dart';

class SettingInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('앱 정보', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1D1B20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset(
                  'assets/logo.png',
                  height: 100,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '버스 정보 승하차 알리미',
                style: TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                '이 앱은 공공데이터포탈(data.go.kr)의 정보를 기반으로\n버스 정보를 제공합니다.',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code, color: Colors.white), // GitHub icon
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    'https://github.com/DY-FlutterClass-2024/bus_info_app.git',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '© Copyright 2024. suzukaotto All rights reserved.',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF1D1B20),
    );
  }
}