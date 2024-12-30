import 'package:flutter/material.dart';
import '../widgets/common_appbar.dart'; // AppBar 파일 import

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '지도 뷰어', // 화면 별 제목 설정
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/nearByStation');
              },
              child: Text('주변정류소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manageShc');
              },
              child: Text('승하차관리'),
            ),
          ],
        ),
      ),
    );
  }
}