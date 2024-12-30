import 'package:flutter/material.dart';

class ManageShcScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1B20),
      body: Center(
        child: Text(
          '설정된 승하차 알림이 없습니다',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}