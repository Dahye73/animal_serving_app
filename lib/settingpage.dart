import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'loginpage.dart';
import 'bottomNavigationBar.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 2;
  bool _isSwitched = false;
  bool _SMSswitched = false;
  bool _emailswitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Setting",
              style: TextStyle(fontSize: 17.0),
            ),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            actions: [
              TextButton(
                child: Icon(
                  Icons.logout,
                  color: const Color.fromARGB(255, 53, 53, 53),
                ),
                onPressed: () {
                  context.read<AuthService>().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("앱 push 알림"),
                ),
                Switch(
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                    });
                  },
                  activeColor:
                      Color.fromARGB(217, 173, 78, 180), // 스위치가 ON 상태일 때의 색상
                  inactiveThumbColor: Color.fromARGB(
                      255, 159, 159, 159), // 스위치가 OFF 상태일 때의 Thumb의 색상
                  inactiveTrackColor: Color.fromARGB(
                      0, 171, 157, 157), // 스위치가 OFF 상태일 때의 Track의 색상
                ),
              ],
            ),
            SizedBox(height: 30),
            Text("마케팅 정보 수신 동의"),
            Text(
              "다양한 소식과 이벤트/혜택 등 정보를 SMS나 이메일로 받아보실 수 있습니다.",
              style: TextStyle(fontSize: 9),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text("SMS"),
                ),
                Switch(
                  value: _SMSswitched,
                  onChanged: (value) {
                    setState(() {
                      _SMSswitched = value;
                    });
                  },
                  activeColor:
                      Color.fromARGB(217, 173, 78, 180), // 스위치가 ON 상태일 때의 색상
                  inactiveThumbColor: Color.fromARGB(
                      255, 159, 159, 159), // 스위치가 OFF 상태일 때의 Thumb의 색상
                  inactiveTrackColor: Color.fromARGB(
                      0, 171, 157, 157), // 스위치가 OFF 상태일 때의 Track의 색상
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text("이메일"),
                ),
                Switch(
                  value: _emailswitched,
                  onChanged: (value) {
                    setState(() {
                      _emailswitched = value;
                    });
                  },
                  activeColor:
                      Color.fromARGB(217, 173, 78, 180), // 스위치가 ON 상태일 때의 색상
                  inactiveThumbColor: Color.fromARGB(
                      255, 159, 159, 159), // 스위치가 OFF 상태일 때의 Thumb의 색상
                  inactiveTrackColor: Color.fromARGB(
                      0, 171, 157, 157), // 스위치가 OFF 상태일 때의 Track의 색상
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        parentContext: context,
      ),
    );
  }
}
