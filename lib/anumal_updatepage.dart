import 'package:bucket_list_with_firebase2/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Streamingpage.dart';
import 'bottomNavigationBar.dart';
import 'loginpage.dart';
import 'main.dart';
import 'information_service.dart';

class PetEditPage extends StatefulWidget {
  final String petName;

  PetEditPage({required this.petName});

  @override
  _PetEditPageState createState() => _PetEditPageState(petName: petName);
}

class _PetEditPageState extends State<PetEditPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  String? petName;
  List<String> petNames = [];
  List<String> petSexs = [];
  List<String> petAges = [];
  List<String> petWeights = [];
  int _selectedIndex = 0;

  _PetEditPageState({required this.petName});

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    FirebaseFirestore.instance
        .collection('pet')
        .where('petname', isEqualTo: petName)
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        var document = querySnapshot.docs.first;
        setState(() {
          _nameController.text = document['petname'];
          _weightController.text = document['petweight'];
        });
      }
      querySnapshot.docs.forEach((doc) {
        setState(() {
          petNames.add(doc.get('petname'));
          petSexs.add(doc.get('petsex'));
          petAges.add(doc.get('petage'));
          petWeights.add(doc.get('petweight'));
          petName = petNames.first;
        });
      });
    });
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
              mainAxisAlignment: MainAxisAlignment.center,
              // 성별 정보와 suffix를 중앙에 위치
              children: [
                Text(
                  text2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4), // 텍스트 사이의 공간을 띄움
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 15,
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

  Future<void> _deletePetFromFirestore(String petName) async {
    final user = context.read<AuthService>().currentUser();
    final uid = user?.uid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('${petName} 등록을 취소합니다.'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 186, 181, 244),
              ),
              child: Text('확인'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('pet')
                    .where('uid', isEqualTo: uid)
                    .where('petname', isEqualTo: petName)
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    doc.reference.delete();
                    setState(() {
                      petNames.remove(petName);
                    });
                  });
                });
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyApp()),
                );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // 화면 크기 가져오기
    double width_margin = size.width * 0.05; // 마진주기
    double boxWidthFraction = 0.95; // 반려동물 박스 화면 80%
    double boxHeight = size.height * 0.28;
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
            automaticallyImplyLeading: true,
            title: Text(
              "정보수정",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            Container(
              height: size.height * 0.28,
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: boxWidthFraction,
                  keepPage: false,
                ),
                itemCount: petNames.length,
                itemBuilder: (context, index) {
                  double iconHeight = boxHeight * 0.55;
                  double smallBoxSize_w = boxHeight * 0.44; // 반려동물 3박스 사이즈
                  double smallBoxSize_h = boxHeight * 0.27;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: (index == 0) ? width_margin / 2 : 0.0,
                      right: width_margin / 2,
                    ),
                    child: GestureDetector(
                      child: Card(
                        elevation: 2,
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  // Spacer를 사용하여 남은 공간을 모두 차지하게 만듭니다.
                                  IconButton(
                                    onPressed: () {
                                      _deletePetFromFirestore(petName!);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 255, 18, 18),
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
              padding: EdgeInsets.fromLTRB(16.0, 23.0, 16.0, 16.0), // 여백 조정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 가로 상단 정렬
                children: [
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Colors.deepPurple,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      labelText: '이름',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 189, 189, 204),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 195, 195)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 195, 195)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 137, 137, 137)),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _weightController,
                    cursorColor: Colors.deepPurple,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      labelText: '몸무게',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 189, 189, 204),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 195, 195)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 195, 195)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 137, 137, 137)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Container(
                    width: MediaQuery.of(context).size.width, // 화면의 넓이를 사용
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
                      onPressed: () {
                        _updatePetInfo();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
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
                          TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal),
                        ),
                      ),
                      child: Text(
                        '수정',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
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

  void _updatePetInfo() {
    String name = _nameController.text;
    String weight = _weightController.text;

    // 입력값이 비어있는 경우 수정하지 않고 팝업 창 표시
    if (name.isEmpty || weight.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('수정 실패'),
            content: Text('이름과 몸무게를 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    FirebaseFirestore.instance
        .collection('pet')
        .where('petname', isEqualTo: petName)
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        var document = querySnapshot.docs.first;
        String documentId = document.id;

        FirebaseFirestore.instance.collection('pet').doc(documentId).update({
          'petname': name,
          'petweight': weight,
        }).then((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('수정 완료'),
                content: Text('반려동물 정보가 수정되었습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // PetEditPage 이전 페이지로 이동
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        }).catchError((error) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('수정 실패'),
                content: Text('반려동물 정보 수정 중 오류가 발생했습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        });
      }
    });
  }
}
