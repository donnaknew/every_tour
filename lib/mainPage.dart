import 'package:every_tour/main/favoritePage.dart';
import 'package:every_tour/main/mapPage.dart';
import 'package:every_tour/main/settingPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MainPage extends StatefulWidget {
  final Future<Database> database;

  MainPage(this.database);

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }

}

class _MainPage extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController? controller;
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String? id;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    _database = FirebaseDatabase.instance;
    reference = _database!.ref();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      body: TabBarView(
        children: [
          MapPage(databaseReference: reference, db: widget.database, id: id,),
          FavoritePage(databaseReference: reference, db: widget.database, id: id,),
          SettingPage(databaseReference: reference, id: id,)
        ],
        controller: controller,
      ),
      bottomNavigationBar: TabBar(
        tabs: [
          Tab(
            icon: Icon(Icons.map),
          ),
          Tab(
            icon: Icon(Icons.star),
          ),
          Tab(
            icon: Icon(Icons.settings),
          ),
        ],
        labelColor: Colors.black12,
        indicatorColor: Colors.black,
        controller: controller,
      ),
    );
  }

}