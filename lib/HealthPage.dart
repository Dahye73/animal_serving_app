import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'bucket_service.dart';
import 'loginpage.dart';

class HealthPage extends StatefulWidget {
  @override
  final String petName;

  HealthPage({required this.petName});

  _HealthPage createState() => _HealthPage(petName: petName);
}

class _HealthPage extends State<HealthPage> {
  final String petName;
  _HealthPage({required this.petName});

  DateTime? _selectedDay;
  String? selecteday;
  String? HealthDate;
  Map<DateTime, String> healthtext = {};

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    final user = context.read<AuthService>().currentUser();
    final uid = user?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('pet')
        .where('uid', isEqualTo: uid)
        .where('petname', isEqualTo: petName)
        .get();

    final healthDoc = querySnapshot.docs.first.id;

    final healthSnapshot = await FirebaseFirestore.instance
        .collection('pet')
        .doc(healthDoc)
        .collection('health')
        .get();

    healthtext = {}; // healthtext 초기화

    healthSnapshot.docs.forEach((doc) {
      final healthDate = (doc.get('date') as Timestamp).toDate();
      final healthTemperature = doc.get('temperature') as String;
      final healthWeight = doc.get('weight') as String;

      // 선택된 날짜와 일치하는지 확인
      if (_selectedDay != null &&
          healthDate.year == _selectedDay!.year &&
          healthDate.month == _selectedDay!.month &&
          healthDate.day == _selectedDay!.day) {
        healthtext[_selectedDay!.toLocal()] =
            '측정날짜 : ${healthDate.year}-${healthDate.month}-${healthDate.day} \n' +
                '$petName 의 무게 : $healthWeight \n' +
                '$petName 의 체온 : $healthTemperature';
      }
    });

    setState(() {});
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

      selecteday = _selectedDay.toString().split('')[0];
    });

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: Text(
              "${petName}의 건강상태",
              style: TextStyle(fontSize: 20.0),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Text(
              '최근 기록된 반려동물의 건강정보',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(
            thickness: 1.0,
            color: Colors.grey[400],
            indent: 3.0,
            endIndent: 3.0,
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 16.0),
                TableCalendar(
                  calendarFormat: CalendarFormat.week,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  focusedDay: _selectedDay ?? DateTime.now(),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  firstDay: DateTime.utc(DateTime.now().year - 1),
                  lastDay: DateTime.utc(DateTime.now().year + 1),
                  calendarStyle: CalendarStyle(),
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedDay != null &&
                                isSameDay(_selectedDay!, date)
                            ? Color.fromARGB(255, 186, 181, 244)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    todayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                ),
                SizedBox(height: 40.0),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        healthtext[_selectedDay] ?? '측정기록이 없습니다.',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
