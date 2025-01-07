import 'package:flutter/material.dart';

class SettingNotificationsScreen extends StatefulWidget {
  const SettingNotificationsScreen({super.key});

  @override
  SettingNotificationsScreenState createState() =>
      SettingNotificationsScreenState();
}

class SettingNotificationsScreenState
    extends State<SettingNotificationsScreen> {
  bool _isNotificationsEnabled = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        title: Text('알림 설정', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1D1B20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isAndroid
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text('알림 활성화', style: TextStyle(color: Colors.white)),
                    value: _isNotificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey,
                  ),
                  if (_isNotificationsEnabled) ...[
                    SwitchListTile(
                      title: Text('소리', style: TextStyle(color: Colors.white)),
                      value: _isSoundEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isSoundEnabled = value;
                        });
                      },
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                    ),
                    SwitchListTile(
                      title: Text('진동', style: TextStyle(color: Colors.white)),
                      value: _isVibrationEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isVibrationEnabled = value;
                        });
                      },
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                    )
                  ],
                ],
              ),
            )
          : Center(
              child: Text(
                '안드로이드 환경에서만 지원됩니다.',
                style: TextStyle(color: Colors.white),
              ),
            ),
      backgroundColor: Color(0xFF1D1B20),
    );
  }
}