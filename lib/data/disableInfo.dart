import 'package:firebase_database/firebase_database.dart';

class DisableInfo {
  String? key;
  int? disable1;
  int? disable2;
  String? id;
  String? createTime;

  DisableInfo(this.id, this.disable1, this.disable2, this.createTime);

  DisableInfo.fromSnapshot(DataSnapshot dataSnapshot)
      :
        key = dataSnapshot.key,
        id = (dataSnapshot.value as Map<dynamic, dynamic>)['id'],
        disable1 = (dataSnapshot.value as Map<dynamic, dynamic>)['disable1'],
        disable2 = (dataSnapshot.value as Map<dynamic, dynamic>)['disable2'],
        createTime = (dataSnapshot.value as Map<dynamic, dynamic>)['createTime'];

  toJson() {
    return {
      'id': id,
      'disable1': disable1,
      'disable2': disable2,
      'createTime': createTime
    };
  }
}