import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'bucket_service.dart';
import 'loginpage.dart';

class DistributePage extends StatefulWidget {
  @override
  final String petName;

  DistributePage({required this.petName});

  _DistributePage createState() => _DistributePage(petName: petName);
}

class _DistributePage extends State<DistributePage> {
  DateTime? _selectedDay;
  String? selectedDay;
  String? recordDate;
  List<String> feedingRecords = []; // 변경: 여러 배식 기록을 저장하기 위한 리스트
  final String petName;

  _DistributePage({required this.petName});

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

    final recordDoc = querySnapshot.docs.first.id;

    final recordSnapshot = await FirebaseFirestore.instance
        .collection('pet')
        .doc(recordDoc)
        .collection('record')
        .get();

    feedingRecords.clear(); // 변경: 이전 기록을 초기화

    recordSnapshot.docs.forEach((doc) {
      final remainingFoodData = doc.data()['남은배식량'] as Map<String, dynamic>;
      final remainingFoodDate =
          (remainingFoodData['date'] as Timestamp).toDate();
      final remainingFoodWeight = remainingFoodData['weight'] as String;

      final feedingAmountData = doc.data()['배식량'] as Map<String, dynamic>;
      final feedingAmountDate =
          (feedingAmountData['date'] as Timestamp).toDate();
      final feedingAmountWeight = feedingAmountData['weight'] as String;

      final recordDate = feedingAmountDate.toString().split(' ')[0];
      this.recordDate = recordDate;

      if (selectedDay == recordDate) {
        final record = '${_formatDateTime(feedingAmountDate)}\n' +
            '남은 배식량: ${remainingFoodWeight}g\n' +
            '배식량: ${feedingAmountWeight}g';
        feedingRecords.add(record); // 변경: 배식 기록을 리스트에 추가
      }
    });

    setState(() {});
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

      this.selectedDay = _selectedDay!.toString().split(' ')[0];
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
              "${petName}의 배식",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 기록된 배식량 변화',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Divider(
              thickness: 1.0,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold, // 날짜 텍스트 강조
                          ),
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
                  SizedBox(height: 24.0),
                  Text(
                    '배식 기록',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    thickness: 1.0,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: feedingRecords.length,
                      itemBuilder: (context, index) {
                        final record = feedingRecords[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              record,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
