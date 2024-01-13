import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'loginpage.dart';
import 'bottomNavigationBar.dart';

class InfoChangePage extends StatefulWidget {
  @override
  _InfoChangePageState createState() => _InfoChangePageState();
}

class _InfoChangePageState extends State<InfoChangePage> {
  int _selectedIndex = 3;
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';

  Future<void> _changePassword() async {
    try {
      User user = FirebaseAuth.instance.currentUser!;

      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: _currentPassword);
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(_newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 변경되었습니다.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

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
              "Information",
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Text(
                '현재 비밀번호',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 2),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: "password",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 189, 189, 204),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 195, 195, 195)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 195, 195, 195)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 137, 137, 137)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _currentPassword = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return '현재 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
                obscureText: true, // 비밀번호를 숨기기 위해 true로 설정
              ),
              SizedBox(height: 30.0),
              Text(
                '새로운 비밀번호',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 2),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: "password",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 189, 189, 204),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 195, 195, 195)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 195, 195, 195)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 137, 137, 137)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _newPassword = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return '새로운 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
                obscureText: true, // 비밀번호를 숨기기 위해 true로 설정
              ),
              SizedBox(height: 30.0),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(189, 255, 215, 238), // 시작 색
                      Color.fromARGB(136, 220, 180, 250), // 끝 색
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Color.fromARGB(255, 154, 100, 255)
                              .withOpacity(0.5);
                        return null;
                      },
                    ),
                    elevation: MaterialStateProperty.all(0),
                    side: MaterialStateProperty.all(BorderSide.none),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                    ),
                  ),
                  child: Text("비밀번호 변경"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _changePassword();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        parentContext: context,
      ),
    );
  }
}
