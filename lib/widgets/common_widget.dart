import 'package:flutter/material.dart';

class CommonWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CommonWidget({Key? key, required this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Center(child: Text(title, style: TextStyle(color: Colors.white))),
      actions: actions ?? [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            debugPrint("Settings clicked!");
          },
        ),
      ],
      backgroundColor: Color(0xFF1D1B20),
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3, // Set the width to 50% of the screen width
        color: Colors.black87,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  '메뉴',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('홈', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_bus, color: Colors.white),
              title: Text('주변 정류소', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/nearByStation');
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts, color: Colors.white),
              title: Text('승하차 관리', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/manageShc');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('설정', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text('앱 종료', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // 메뉴 닫기
              },
            ),
          ],
        ),
      ),
    );
  }
}
