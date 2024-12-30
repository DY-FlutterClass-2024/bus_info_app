import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = '한국어';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1D1B20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language, color: Colors.white),
            title: Text('언어', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Color(0xFF1D1B20),
              icon: Icon(Icons.arrow_downward, color: Colors.white),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: <String>['한국어', 'English(지원X)', '日本語(지원X)']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            onTap: () {
              // Navigate to language settings
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.white),
            title: Text('알림', style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.pushNamed(context, '/settings/nofications');
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.white),
            title: Text('앱 정보', style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.pushNamed(context, '/settings/info');
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFF1D1B20),
    );
  }
}