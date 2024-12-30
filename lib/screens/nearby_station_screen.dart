import 'package:flutter/material.dart';
import '../widgets/common_appbar.dart'; // AppBar 파일 import

class NearbyStationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '주변정류소', // 다른 화면의 제목 설정
      ),
      body: Center(
        child: Text('This is the Nearby station screen!'),
      ),
    );
  }
}