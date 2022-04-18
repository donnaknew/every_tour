import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Review {
  String id;
  String review;
  String createTime;

  Review(this.id, this.review, this.createTime);

  Review.fromSnapshot(DataSnapshot dataSnapshot)
      :
        id = (dataSnapshot.value as Map<dynamic, dynamic>)['id'],
        review = (dataSnapshot.value as Map<dynamic, dynamic>)['review'],
        createTime = (dataSnapshot.value as Map<dynamic, dynamic>)['createTime'];

  toJson() {
    return {
      'id': this.id,
      'review': this.review,
      'createTime': this.createTime
    };
  }
}