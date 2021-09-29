import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectschedule/controller/models_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Structure {
  int? bigProjectKey;
  List<int>? middleTaskKeyList;
  List<int>? smallTaskKeyList;
  String? bigProjectName;
  List<String>? middleTaskNameList;
  List<String>? smallTaskNameList;
  double? bigProjectPercent;
  List<double>? middleTaskPercentList;
  List<double>? smallTaskPercentList;
}

class BigPage extends StatefulWidget {
  const BigPage({Key? key}) : super(key: key);
  static final routeName = '/bigPage';

  @override
  _BigPageState createState() => _BigPageState();
}

class _BigPageState extends State<BigPage> {
  final ModelsController controller = Get.find<ModelsController>();

  late String? bigProjectName;
  late double bigProjectPercent;
  late DateTime? bigProjectDateTime;
  late DateTime? bigProjectDeadline;
  late DateTime? bigProjectCompletedTime;
  late String? bigProjectDescription;
  TextEditingController textEditingController = TextEditingController();
  late int? daysLeft;
  late double? target;
  late bool willDelete;
  late bool? archive;
  late int bigProjectKey;

  bool isInitial = true;

  String _popupMenuSelectedValue = "";

  String? _middleTaskPopupMenuSelectedValue;

  int? middleTaskListLength = null;

  final firestoreInstance = FirebaseFirestore.instance;

  List<DocumentSnapshot>? _docs;

  Future? _saving;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if(isInitial) {
      bigProjectName = Get.arguments['bigProjectName'];
      bigProjectPercent = Get.arguments['bigProjectPercent'];
      bigProjectDateTime = Get.arguments['bigProjectDateTime'].toDate();
      bigProjectDeadline = Get.arguments['bigProjectDeadline'] == null
          ? Get.arguments['bigProjectDeadline'] : Get.arguments['bigProjectDeadline'].toDate();
      bigProjectCompletedTime = Get.arguments['bigProjectCompletedTime'] == null
          ? Get.arguments['bigProjectCompletedTime'] : Get.arguments['bigProjectCompletedTime'].toDate();
      bigProjectDescription = Get.arguments['bigProjectDescription'];
      if(bigProjectDescription != null){
        textEditingController.text = bigProjectDescription!;
      }
      daysLeft = Get.arguments['daysLeft'];
      target = Get.arguments['target'];
      willDelete = Get.arguments['willDelete'];
      archive = Get.arguments['archive'];
      bigProjectKey = Get.arguments['bigProjectKey'];
      isInitial = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${bigProjectName}",
          style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),
          ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            //update part
            // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
            target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
            // await controller.bigProjectCompletedTimeUpdate(bigProject);
            //update part end
            Get.back(result: willDelete);
          },
        ),
        actions:[
          IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: (){},
          ),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.blue
              )
            ),
            child: PopupMenuButton(
              icon: Icon(Icons.menu, color: Colors.white,),
              elevation: 16,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Edit name", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),),
                  value: "Edit name",
                ),
                PopupMenuItem(
                  child: Text("Copy", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),),
                  value: "Copy",
                ),
                PopupMenuItem(
                  child: Text("Delete this project", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),),
                  value: "Delete this project",
                ),
                PopupMenuItem(
                  child: Text("Archive", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),),
                  value: "Archive",
                ),
              ],
              onSelected: (value) async {
                _popupMenuSelectedValue = value as String;
                //update part
                if(_popupMenuSelectedValue == "Edit name"){
                  bigProjectName = await controller.bigProjectNameEdit(context, bigProjectKey, _popupMenuSelectedValue, bigProjectName);
                }
                if(_popupMenuSelectedValue == "Copy"){
                  //await controller.bigProjectCopy(context, bigProject, _popupMenuSelectedValue);
                }
                if(_popupMenuSelectedValue == "Delete this project"){
                  await controller.bigProjectDeleteCheck(context, bigProjectName, willDelete, _popupMenuSelectedValue);
                }
                if(_popupMenuSelectedValue == "Archive"){
                  archive = await controller.bigProjectArchive(context, bigProjectKey, archive, _popupMenuSelectedValue);
                }
                //update part end

                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "전체",
                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                        "${bigProjectPercent.floor()}",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',fontSize: 30)
                                    ),
                                    Text(
                                        "%",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                    )
                                  ],
                                ),
                                Text(
                                  "0%",
                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: size.height*0.015,
                        ),
                        Container(
                          width: size.width*0.9,
                          height: 10,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey,
                                ),
                              ),
                              FractionallySizedBox(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.blue
                                  ),
                                ),
                                widthFactor: bigProjectPercent/100,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        Row(
                          children: [
                            Icon(Icons.wysiwyg),
                            Container(
                              width: size.width*0.03,
                            ),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Color(0xFFF7F7F7),
                              child: TextButton(
                                child: Text(
                                  "${bigProjectDateTime?.year}-"
                                      "${bigProjectDateTime?.month}-"
                                      "${bigProjectDateTime?.day}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'NotoSansCJKkrMedium'
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  bigProjectDateTime = await controller.startBigProjectDateTimePickerUpdate(context, bigProjectKey, bigProjectDateTime, bigProjectDeadline);
                                  daysLeft = await controller.bigProjectDaysLeftUpdate(daysLeft, bigProjectKey, bigProjectDateTime, bigProjectDeadline);
                                  target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            ),
                            Container(
                              width: size.width*0.015,
                            ),
                            Text(
                              "-",
                              style: TextStyle(
                                  fontFamily: 'NotoSansCJKkrMedium'
                              ),
                            ),
                            Container(
                              width: size.width*0.015,
                            ),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Color(0xFFF7F7F7),
                              child: TextButton(
                                child: bigProjectDeadline != null ? Text(
                                  "${bigProjectDeadline?.year}-"
                                      "${bigProjectDeadline?.month}-"
                                      "${bigProjectDeadline?.day}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium',
                                  ),
                                ) : Text(
                                  "No Deadline",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontFamily: 'NotoSansCJKkrMedium',
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  bigProjectDeadline = await controller.deadlineBigProjectPickerUpdate(context, bigProjectKey, bigProjectDateTime, bigProjectDeadline);
                                  daysLeft = await controller.bigProjectDaysLeftUpdate(daysLeft, bigProjectKey, bigProjectDateTime, bigProjectDeadline);
                                  target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: size.height*0.02,
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined),
                            Container(
                              width: size.width*0.03,
                            ),
                            bigProjectDeadline != null ?
                            DateTime(bigProjectDeadline!.year, bigProjectDeadline!.month, bigProjectDeadline!.day)
                                .difference(DateTime(bigProjectDateTime!.year, bigProjectDateTime!.month, bigProjectDateTime!.day)
                            ).inDays == 0?
                            Text("남은 날짜: 오늘 마감", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),) :
                            Text("남은 날짜: ${daysLeft} 일", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',)) :
                            Text("남은 날짜: -", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',)),
                          ],
                        ),
                        Container(
                          height: size.height*0.02,
                        ),
                        Row(
                          children: [
                            Icon(Icons.check_box_outlined),
                            Container(
                              width: size.width*0.03,
                            ),
                            bigProjectDeadline != null ?
                            Text("남은 매일 목표량: ${target}% /day", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',)) :
                            Text("남은 매일 목표량: - /day", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',)),
                          ],
                        ),
                        Container(
                          height: size.height*0.02,
                        ),
                        Row(
                          children: [
                            Icon(Icons.article_outlined),
                            Container(
                              width: size.width*0.03,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFFE8E8E8),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xFFE8E8E8),
                              ),
                              child: SizedBox(
                                width: size.width*0.78,
                                child: ListTile(
                                  title: bigProjectDescription != null ?
                                  Text(
                                    "${bigProjectDescription}",
                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                  ) :
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontFamily: 'NotoSansCJKkrMedium',
                                    ),
                                  ),
                                  onTap: () async {
                                    //update part
                                    bigProjectDescription = await controller.bigProjectDescriptionUpdate(context, bigProjectKey, bigProjectDescription, textEditingController);
                                    //update part end

                                    setState(() {});
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                child: Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tasks", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
                          PopupMenuButton(
                            icon: Icon(Icons.menu),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text("Custom Order", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                value: "Custom Order",
                              ),
                              PopupMenuItem(
                                child: Text("Registration Order", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                value: "Registration Order",
                              ),
                              PopupMenuItem(
                                child: Text("Oldest First", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                value: "Oldest First",
                              ),
                            ],
                            onSelected: (value) async {
                              _middleTaskPopupMenuSelectedValue = value as String?;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    _middleTaskPopupMenuSelectedValue == "Custom Order" ? StreamBuilder<QuerySnapshot>(
                        stream: firestoreInstance.collection("middleTaskList").orderBy('middleTaskSortingNumber', descending: false).snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            middleTaskListLength = snapshot.data!.docs.length;
                            _docs = snapshot.data!.docs;
                            return ReorderableListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if(snapshot.data!.docs[index]['bigProjectKey'] == bigProjectKey){
                                  return ListTile(
                                    key: Key('$index'),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                snapshot.data!.docs[index]['middleTaskPercent'] != 100 ?
                                                Icon(Icons.insert_drive_file_outlined) :
                                                Stack(
                                                  children: [
                                                    Icon(Icons.insert_drive_file_outlined),
                                                    Icon(Icons.check)
                                                  ],
                                                ),
                                                Container(
                                                  width: size.width*0.03,
                                                ),
                                                SizedBox(
                                                  width: size.width*0.4,
                                                  child: Text(
                                                    "${snapshot.data!.docs[index]['middleTaskName']}",
                                                    softWrap: true,
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 15,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.blue
                                                          ),
                                                        ),
                                                        widthFactor: snapshot.data!.docs[index]['middleTaskPercent']/100,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width*0.03,
                                                ),
                                                Text("${snapshot.data!.docs[index]['middleTaskPercent'].floor()}%",
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      bool result = await Get.toNamed(
                                          '/middlePage',
                                          arguments: {
                                            'middleTaskName' : snapshot.data!.docs[index]['middleTaskName'],
                                            'middleTaskPercent' : snapshot.data!.docs[index]['middleTaskPercent'],
                                            'middleTaskDateTime' : snapshot.data!.docs[index]['middleTaskDateTime'],
                                            'middleTaskDeadline' : snapshot.data!.docs[index]['middleTaskDeadline'],
                                            'middleTaskDescription' : snapshot.data!.docs[index]['middleTaskDescription'],
                                            'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                            'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                            'middleTaskKey' : snapshot.data!.docs[index]['middleTaskKey'],
                                          }
                                      );

                                      //update part
                                      // await controller.middleTaskDelete(result, middleTaskList, index);
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end

                                      setState(() {});
                                    },
                                  );
                                }
                                else{
                                  return Container(
                                      key: Key('$index')
                                  );
                                }
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  //update part
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  _docs?.insert(newIndex, _docs!.removeAt(oldIndex));
                                  final futures = <Future>[];
                                  for (int pos = 0; pos < _docs!.length; pos++) {
                                    futures.add(_docs![pos].reference.update({'middleTaskSortingNumber': pos}));
                                  }
                                  setState(() {
                                    _saving = Future.wait(futures);
                                  });
                                  //update part end
                                });
                              },
                            );
                          }
                          else{
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                              ),
                            );
                          }
                        }
                    ) :
                    _middleTaskPopupMenuSelectedValue == "Registration Order" ? StreamBuilder<QuerySnapshot>(
                        stream: firestoreInstance.collection("middleTaskList").orderBy('middleTaskRegistrationDateTime', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            middleTaskListLength = snapshot.data!.docs.length;
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if(snapshot.data!.docs[index]['bigProjectKey'] == bigProjectKey){
                                  return ListTile(
                                    key: Key('$index'),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                snapshot.data!.docs[index]['middleTaskPercent'] != 100 ?
                                                Icon(Icons.insert_drive_file_outlined) :
                                                Stack(
                                                  children: [
                                                    Icon(Icons.insert_drive_file_outlined),
                                                    Icon(Icons.check)
                                                  ],
                                                ),
                                                Container(
                                                  width: size.width*0.03,
                                                ),
                                                SizedBox(
                                                  width: size.width*0.4,
                                                  child: Text(
                                                    "${snapshot.data!.docs[index]['middleTaskName']}",
                                                    softWrap: true,
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 15,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.blue
                                                          ),
                                                        ),
                                                        widthFactor: snapshot.data!.docs[index]['middleTaskPercent']/100,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width*0.03,
                                                ),
                                                Text("${snapshot.data!.docs[index]['middleTaskPercent'].floor()}%",
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      bool result = await Get.toNamed(
                                          '/middlePage',
                                          arguments: {
                                            'middleTaskName' : snapshot.data!.docs[index]['middleTaskName'],
                                            'middleTaskPercent' : snapshot.data!.docs[index]['middleTaskPercent'],
                                            'middleTaskDateTime' : snapshot.data!.docs[index]['middleTaskDateTime'],
                                            'middleTaskDeadline' : snapshot.data!.docs[index]['middleTaskDeadline'],
                                            'middleTaskDescription' : snapshot.data!.docs[index]['middleTaskDescription'],
                                            'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                            'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                            'middleTaskKey' : snapshot.data!.docs[index]['middleTaskKey'],
                                          }
                                      );

                                      //update part
                                      // await controller.middleTaskDelete(result, middleTaskList, index);
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end

                                      setState(() {});
                                    },
                                  );
                                }
                                else{
                                  return Container();
                                }
                              },
                            );
                          }
                          else{
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                              ),
                            );
                          }
                        }
                    ) :
                    _middleTaskPopupMenuSelectedValue == "Oldest First" ? StreamBuilder<QuerySnapshot>(
                        stream: firestoreInstance.collection("middleTaskList").orderBy('middleTaskRegistrationDateTime', descending: false).snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            middleTaskListLength = snapshot.data!.docs.length;
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if(snapshot.data!.docs[index]['bigProjectKey'] == bigProjectKey){
                                  return ListTile(
                                    key: Key('$index'),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                snapshot.data!.docs[index]['middleTaskPercent'] != 100 ?
                                                Icon(Icons.insert_drive_file_outlined) :
                                                Stack(
                                                  children: [
                                                    Icon(Icons.insert_drive_file_outlined),
                                                    Icon(Icons.check)
                                                  ],
                                                ),
                                                Container(
                                                  width: size.width*0.03,
                                                ),
                                                SizedBox(
                                                  width: size.width*0.4,
                                                  child: Text(
                                                    "${snapshot.data!.docs[index]['middleTaskName']}",
                                                    softWrap: true,
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 15,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.blue
                                                          ),
                                                        ),
                                                        widthFactor: snapshot.data!.docs[index]['middleTaskPercent']/100,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width*0.03,
                                                ),
                                                Text("${snapshot.data!.docs[index]['middleTaskPercent'].floor()}%",
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      bool result = await Get.toNamed(
                                          '/middlePage',
                                          arguments: {
                                            'middleTaskName' : snapshot.data!.docs[index]['middleTaskName'],
                                            'middleTaskPercent' : snapshot.data!.docs[index]['middleTaskPercent'],
                                            'middleTaskDateTime' : snapshot.data!.docs[index]['middleTaskDateTime'],
                                            'middleTaskDeadline' : snapshot.data!.docs[index]['middleTaskDeadline'],
                                            'middleTaskDescription' : snapshot.data!.docs[index]['middleTaskDescription'],
                                            'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                            'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                            'middleTaskKey' : snapshot.data!.docs[index]['middleTaskKey'],
                                          }
                                      );

                                      //update part
                                      // await controller.middleTaskDelete(result, middleTaskList, index);
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end

                                      setState(() {});
                                    },
                                  );
                                }
                                else{
                                  return Container();
                                }
                              },
                            );
                          }
                          else{
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                              ),
                            );
                          }
                        }
                    ) :
                    StreamBuilder<QuerySnapshot>(
                        stream: firestoreInstance.collection("middleTaskList").orderBy('middleTaskSortingNumber', descending: false).snapshots(),
                        builder: (context, snapshot) {
                          print(snapshot.connectionState);
                          if(snapshot.hasData){
                            middleTaskListLength = snapshot.data!.docs.length;
                            _docs = snapshot.data!.docs;
                            return ReorderableListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if(snapshot.data!.docs[index]['bigProjectKey'] == bigProjectKey){
                                  return ListTile(
                                    key: Key('$index'),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                snapshot.data!.docs[index]['middleTaskPercent'] != 100 ?
                                                Icon(Icons.insert_drive_file_outlined) :
                                                Stack(
                                                  children: [
                                                    Icon(Icons.insert_drive_file_outlined),
                                                    Icon(Icons.check)
                                                  ],
                                                ),
                                                Container(
                                                  width: size.width*0.03,
                                                ),
                                                SizedBox(
                                                  width: size.width*0.4,
                                                  child: Text(
                                                    "${snapshot.data!.docs[index]['middleTaskName']}",
                                                    softWrap: true,
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 15,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.blue
                                                          ),
                                                        ),
                                                        widthFactor: snapshot.data!.docs[index]['middleTaskPercent']/100,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width*0.03,
                                                ),
                                                Text("${snapshot.data!.docs[index]['middleTaskPercent'].floor()}%",
                                                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      bool result = await Get.toNamed(
                                          '/middlePage',
                                          arguments: {
                                            'middleTaskName' : snapshot.data!.docs[index]['middleTaskName'],
                                            'middleTaskPercent' : snapshot.data!.docs[index]['middleTaskPercent'],
                                            'middleTaskDateTime' : snapshot.data!.docs[index]['middleTaskDateTime'],
                                            'middleTaskDeadline' : snapshot.data!.docs[index]['middleTaskDeadline'],
                                            'middleTaskDescription' : snapshot.data!.docs[index]['middleTaskDescription'],
                                            'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                            'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                            'middleTaskKey' : snapshot.data!.docs[index]['middleTaskKey'],
                                          }
                                      );

                                      //update part
                                      // await controller.middleTaskDelete(result, middleTaskList, index);
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end

                                      setState(() {});
                                    },
                                  );
                                }
                                else{
                                  return Container(
                                      key: Key('$index')
                                  );
                                }
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  //update part
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  _docs?.insert(newIndex, _docs!.removeAt(oldIndex));
                                  final futures = <Future>[];
                                  for (int pos = 0; pos < _docs!.length; pos++) {
                                    futures.add(_docs![pos].reference.update({'middleTaskSortingNumber': pos}));
                                  }
                                  setState(() {
                                    _saving = Future.wait(futures);
                                  });
                                  //update part end
                                });
                              },
                            );
                          }
                          else{
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                              ),
                            );
                          }
                        }
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          //update part
          await controller.createNewMiddleTask(context, middleTaskListLength, bigProjectKey);
          // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
          target = await controller.bigProjectTargetUpdate(target, bigProjectKey, bigProjectPercent, bigProjectDateTime, bigProjectDeadline);
          // await controller.bigProjectCompletedTimeUpdate(bigProject);
          // update part end

          setState(() { });
        },
      ),
    );
  }
}