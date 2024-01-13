import 'package:bucket_list_with_firebase2/Messaging.dart';
import 'package:bucket_list_with_firebase2/information_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'bucket_service.dart';
import 'addpet_service.dart';
import 'loginpage.dart';
import 'addpetpage.dart';
import 'bucketlistpage.dart';
import 'State_Checkpage.dart';
import 'animal_serving.dart';
import 'animal_serving_service.dart';
import 'Streamingpage.dart';
import 'pet_state_detail.dart';
import 'anumal_updatepage.dart';
import 'information.dart';
import 'package:intl/intl.dart';
import 'bottomNavigationBar.dart';
import 'package:flutter/rendering.dart';
import 'Messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BucketService()),
        ChangeNotifierProvider(create: (context) => AddPetService()),
        ChangeNotifierProvider(create: (context) => AnimalServingService()),
      ],
      child: MyApp(),
    ),
  );
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final NotificationController notificationController =
      Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginPage() : StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<String> petNames = [];
  List<String> petSexs = [];
  List<String> petAges = [];
  List<String> petWeights = [];
  List<String> petValues = [];
  String? petName;
  int _selectedIndex = 0;

  ScrollController scrollController = ScrollController();
  // Selected date index
  int selectedDateIndex = DateTime.now().day - 1;

  DateTime selectedDate = DateTime.now();

  List<DateTime> get datesOfCurrentMonth {
    final DateTime now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return List<DateTime>.generate(
      daysInMonth,
      (index) => DateTime(now.year, now.month, index + 1),
    );
  }

  @override
  void initState() {
    super.initState();

    // ScrollController 초기화
    scrollController = ScrollController();

    // UI 렌더링이 완료된 후에 스크롤 위치를 설정
    Future.delayed(Duration.zero, () {
      // 선택된 날짜의 인덱스를 계산 (0부터 시작)
      selectedDateIndex = DateTime.now().day - 1;
      // 스크롤 위치를 부드럽게 이동
      scrollController.animateTo(
        selectedDateIndex * 80.0, // 80.0은 각 아이템의 너비입니다.
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
    _getPetNamesFromFirestore();
  }

  Future<void> _getPetNamesFromFirestore() async {
    final user = context.read<AuthService>().currentUser();
    final uid = user?.uid;

    FirebaseFirestore.instance
        .collection('pet')
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          petNames.add(doc.get('petname'));
          petSexs.add(doc.get('petsex'));
          petAges.add(doc.get('petage'));
          petWeights.add(doc.get('petweight'));
          //petValues.add(doc.get('petvalue'));
          petName = petNames.first;
        });
      });
    });
  }

  Future<Map<String, dynamic>> getTotalWeightForPet(String petName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final user = context.read<AuthService>().currentUser();
    final uid = user?.uid;

    // 선택한 날짜의 시작과 끝을 나타내는 Timestamp 객체를 생성합니다.
    final Timestamp startOfSelectedDate = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0));
    final Timestamp endOfSelectedDate = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));

    double totalWeight = 0.0;
    int count = 0;

    // 선택한 반려동물의 정보를 Firestore에서 가져옵니다.
    final petQuery = await firestore
        .collection('pet')
        .where('uid', isEqualTo: uid)
        .where('petname', isEqualTo: petName)
        .get();

    for (var petDoc in petQuery.docs) {
      final docId = petDoc.id; // 이것은 문서 ID입니다.

      // 각 반려동물의 'record' 컬렉션 내의 모든 문서를 가져옵니다.
      final recordCollection =
          firestore.collection('pet').doc(docId).collection('record');
      final recordQuerySnapshot = await recordCollection.get();

      for (var recordDoc in recordQuerySnapshot.docs) {
        final Map<String, dynamic> recordData = recordDoc.data() ?? {};

        // '배식량' 필드의 정보를 가져옵니다.
        final Map<String, dynamic> feedingAmount =
            recordData['배식량'] as Map<String, dynamic>? ?? {};

        // '배식량' 필드 내의 'date' 값이 선택한 날짜 범위에 속하는지 확인합니다.
        final Timestamp feedingDate =
            feedingAmount['date'] as Timestamp? ?? Timestamp.now();

        if (feedingDate.compareTo(startOfSelectedDate) >= 0 &&
            feedingDate.compareTo(endOfSelectedDate) <= 0) {
          final String feedingWeightString = feedingAmount['weight'] ?? '0';
          final double feedingWeight =
              double.tryParse(feedingWeightString) ?? 0.0;

          totalWeight += feedingWeight;
          if (feedingWeight > 0.0) {
            count += 1;
          }
        }
      }
    }

    return {
      'totalWeight': totalWeight,
      'count': count,
    };
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = context.watch<AuthService>().currentUser();

    var size = MediaQuery.of(context).size; // 화면 크기 가져오기
    double width_margin = size.width * 0.05; // 마진주기
    double boxWidthFraction = 0.8; // 반려동물 박스 화면 80%
    double boxHeight = size.height * 0.25;

    Widget buildUserAvatar() {
      return CircleAvatar(
        child: Icon(Icons.person),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }

    Widget buildUserHeader() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildUserAvatar(),
          SizedBox(height: 16.0),
          Text(
            currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    Widget smallBox(String text1, String text2, String suffix, double w_size,
        double h_size, String hexColor) {
      Color bgColor = Color(int.parse('0x' + hexColor));
      return Container(
        width: w_size,
        height: h_size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // "Gender"를 왼쪽에 정렬
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
            children: [
              Text(
                text1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4), // 위아래 텍스트 사이의 공간을 띄움
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // 성별 정보와 suffix를 중앙에 위치
                children: [
                  Text(
                    text2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4), // 텍스트 사이의 공간을 띄움
                  Text(
                    suffix,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    String getDayInKorean(String day) {
      switch (day) {
        case 'Mon':
          return '월';
        case 'Tue':
          return '화';
        case 'Wed':
          return '수';
        case 'Thu':
          return '목';
        case 'Fri':
          return '금';
        case 'Sat':
          return '토';
        case 'Sun':
          return '일';
        default:
          return '';
      }
    }

// Function to build a date box
    Widget buildDateBox(DateTime date, int index) {
      String day =
          DateFormat('EEE').format(date); // Get the day name (Mon, Tue, ...)
      String dayOfMonth =
          DateFormat('d').format(date); // Get the day of the month (1, 2, ...)
      String dayInKorean = getDayInKorean(day); // Convert day to Korean

      double width = MediaQuery.of(context).size.width;
      double boxWidth = width * 0.20; // 20% of screen width
      double spacing = width * 0.05; // 5% of screen width

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedDateIndex = index;
            selectedDate = date; // Update the selected date index
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: Container(
            width: boxWidth,
            decoration: BoxDecoration(
              color: (selectedDateIndex == index)
                  ? Color.fromARGB(164, 245, 205, 232)
                  : Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(3, 3),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(dayInKorean,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(dayOfMonth,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildPetActionBox(
        String petName, IconData iconData, String actionText, int count) {
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- 이 부분을 추가
          children: [
            Row(
              // <-- 이 부분을 추가하여 아이콘과 텍스트를 하나의 Row로 그룹화
              children: [
                Icon(
                  iconData,
                  size: 40,
                ),
                SizedBox(width: 10),
                Text(
                  '$petName에게 $actionText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '$count', // 카운트 값을 추가
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

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
              "AND",
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
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'My Pets',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 30.0,
                      height: 30.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddPet()),
                          );
                        },
                        child: Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 65, 65, 65),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: size.height * 0.25,
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: boxWidthFraction,
                    keepPage: false,
                  ),
                  itemCount: petNames.length,
                  itemBuilder: (context, index) {
                    double iconHeight = boxHeight * 0.5;
                    double smallBoxSize_w = boxHeight * 0.38; // 반려동물 3박스 사이즈
                    double smallBoxSize_h = boxHeight * 0.295;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: (index == 0) ? width_margin : width_margin / 1.3,
                        right: width_margin / 2,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomePage2(petName: petNames[index]),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          color: Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      // petValues[index] == 'dog'
                                      //     ? Icons.pets
                                      //     : petValues[index] == 'cat'
                                      //         ? Icons.pets
                                      Icons.pets,
                                      size: iconHeight,
                                      color: Color.fromARGB(255, 245, 179, 176),
                                    ),
                                    SizedBox(width: 16),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        '${petNames[index]}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    smallBox(
                                        'Gender',
                                        petSexs[index],
                                        '',
                                        smallBoxSize_w,
                                        smallBoxSize_h,
                                        '80F8B691'), // 성별 표시,
                                    SizedBox(width: 9),
                                    smallBox(
                                        'Ages',
                                        petAges[index],
                                        'Years',
                                        smallBoxSize_w,
                                        smallBoxSize_h,
                                        '80B9D9FF'), // 나이 표시
                                    SizedBox(width: 9),
                                    smallBox(
                                        'Weight',
                                        petWeights[index],
                                        'Kg',
                                        smallBoxSize_w,
                                        smallBoxSize_h,
                                        '60A1E1E5'), // 무게 표시
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬
                  child: Text(
                    'Daily Tasks',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    height: 100,
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      itemCount: datesOfCurrentMonth.length,
                      itemBuilder: (context, index) {
                        DateTime date = datesOfCurrentMonth[index];
                        return buildDateBox(date, index);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: petNames.length,
                itemBuilder: (context, index) {
                  String petName = petNames[index];

                  return FutureBuilder<Map<String, dynamic>>(
                    future: getTotalWeightForPet(petName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        double totalWeight =
                            snapshot.data?['totalWeight'] ?? 0.0;
                        int count = snapshot.data?['count'] ?? 0;

                        if (count == 0) {
                          return SizedBox.shrink(); // 아무런 위젯도 반환하지 않습니다.
                        }

                        String actionText = '$totalWeight' + 'g 배식';
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width_margin / 2,
                            horizontal: width_margin / 2,
                          ),
                          child: buildPetActionBox(
                              petName, Icons.pets, actionText, count),
                        );
                      }
                    },
                  );
                },
              )
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
