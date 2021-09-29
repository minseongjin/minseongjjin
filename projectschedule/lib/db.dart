import 'package:flutter/cupertino.dart';
import 'package:projectschedule/model/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DB {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference firestoreBigProjectList = FirebaseFirestore.instance.collection('bigProjectList');

  static final List<BigProject> bigProjectList = [];

  static Future<void> initBigProjectList() async {
    await Future.delayed(Duration(seconds: 2));

  }

  static Future<void> addBigProject(BigProject newBigProject) async {
    await Future.delayed(Duration(milliseconds: 500));
    bigProjectList.add(newBigProject);
  }

  static Future<List<BigProject>> loadBigProjectList() async {
    await Future.delayed(Duration(seconds: 2)); // 2초를 기다림
    return bigProjectList;
  }
}