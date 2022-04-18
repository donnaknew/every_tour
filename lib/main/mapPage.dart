import 'dart:convert';

import 'package:every_tour/data/tour.dart';
import 'package:every_tour/main/tourDetailPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../data/listData.dart';

class MapPage extends StatefulWidget {
  final DatabaseReference? databaseReference;
  final Future<Database>? db;
  final String? id;

  const MapPage({Key? key, this.databaseReference, this.db, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapPage();
  }

}

class _MapPage extends State<MapPage> {
  List<DropdownMenuItem<Item>> list = List.empty(growable: true);
  List<DropdownMenuItem<Item>> subList = List.empty(growable: true);
  List<TourData> tourData = List.empty(growable: true);
  ScrollController? _scrollController;

  String authKey = 'C%2BFyMC1oEi0s79R0lwpWqA6FiJufGto8MLPSrjKHyJ5261BSDCAyeDfx10pa96wfquYHietyR4MwchL4on75jA%3D%3D';

  Item? area;
  Item? kind;
  int page = 1;

  @override
  void initState() {
    super.initState();
    list = Area().seoulArea;
    subList = Kind().kinds;

    area = list[0].value;
    kind = subList[0].value;

    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if(_scrollController!.offset >= _scrollController!.position.maxScrollExtent && !_scrollController!.position.outOfRange) {
        page++;
        getAreaList(area: area!.value, contentTypeId: kind!.value, page: page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색하기'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  DropdownButton<Item>(
                      items: list,
                      onChanged: (value) {
                        Item selectedItem = value!;
                        setState(() {
                          area = selectedItem;
                        });
                      },
                    value: area,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<Item>(
                    items: subList,
                    onChanged: (value) {
                      Item selectedItem = value!;
                      setState(() {
                        kind = selectedItem;
                      });
                    },
                    value: kind,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      page = 1;
                      tourData.clear();
                      getAreaList(area: area!.value, contentTypeId: kind!.value, page: page);
                    },
                    child: Text('검색하기', style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        child: Row(
                          children: [
                            Hero(
                              tag: 'tourinfo$index',
                              child: Container(
                                margin: EdgeInsets.all(10),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: getImage(tourData[index].imagePath)
                                  )
                                ),
                              )
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    tourData[index].title!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    '주소 : ${tourData[index].address}'
                                  ),
                                  tourData[index].tel != null ? Text('전화번호 : ${tourData[index].tel}') : Container()
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              ),
                              width: MediaQuery.of(context).size.width - 150,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return TourDetailPage(
                                  id:  widget.id,
                                  tourData: tourData[index],
                                  index: index,
                                  databaseReference: widget.databaseReference,
                                );
                              }
                          ));
                        },
                        onDoubleTap: () {
                          insertTour(widget.db!, tourData[index]);
                        },
                      ),
                    );
                  },
                  itemCount: tourData.length,
                  controller: _scrollController,
                )
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  void insertTour(Future<Database> db, TourData info) async {
    final Database database = await db;
    await database.insert('place', info.toMap(), conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('즐겨찾기에 추가되었습니다')));
    });
  }

  ImageProvider getImage(String? imagePath) {
    if(imagePath != null) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage('repo/images/map_location.png');
    }
  }

  void getAreaList({required int area, required int contentTypeId, required int page}) async {
    var url = 'http://api.visitkorea.or.kr/openapi/service/rest/KorService/'
        'areaBasedList?ServiceKey=$authKey&MobileOS=AND&MobileApp=ModuTour&'
        '_type=json&areaCode=1&numOfRows=10&sigunguCode=$area&pageNo=$page';
    if(contentTypeId != 0) {
      url = url + '&contentTypeId=$contentTypeId';
    }
    var response = await http.get(Uri.parse(url));
    String body = utf8.decode(response.bodyBytes);
    print(body);

    var json = jsonDecode(body);
    if(json['response']['header']['resultCode'] == "0000") {
      if(json['response']['body']['items'] == '') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('마지막 데이터 입니다'),
            );
          }
        );
      } else {
        List jsonArray = json['response']['body']['items']['item'];
        for(var s in jsonArray) {
          setState(() {
            tourData.add(TourData.fromJson(s));
          });
        }
      }
    } else {
      print('error');
    }
  }

}