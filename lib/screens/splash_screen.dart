import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/rounded-logo.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  '승하차알리미',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '어플리케이션을 실행합니다 . . .',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'ver 1.0',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '© Copyright 2024. suzukaotto All rights reserved.',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}