import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final DatabaseReference? databaseReference;
  final String? id;

  SettingPage({this.databaseReference, this.id});

  @override
  State<StatefulWidget> createState() {
    return _SettingPage();
  }

}

class _SettingPage extends State<SettingPage> {
  bool pushCheck = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정하기'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Text('푸시 알림', style: TextStyle(fontSize: 20),),
                  Switch(value: pushCheck, onChanged: (value) {
                    setState(() {
                      pushCheck = value;
                    });
                    _setData(value);
                  })
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: Text('로그아웃', style: TextStyle(fontSize: 20),)
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  AlertDialog dialog = new AlertDialog(
                    title: Text('아이디 삭제'),
                    content: Text('아이디를 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          print(widget.id);
                          widget.databaseReference!.child('user').child(widget.id!).remove();
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: Text('예')
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('아니요')
                      )
                    ],
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return dialog;
                    }
                  );
                },
                child: Text('회원 탈퇴', style: TextStyle(fontSize: 20),)
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  void _setData(bool value) async {
    String key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  void _loadData() async {
    String key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var value = pref.getBool(key);
      if (value == null) {
        setState(() {
          pushCheck = true;
        });
      } else {
        setState(() {
          pushCheck = value;
        });
      }
    });
  }
}