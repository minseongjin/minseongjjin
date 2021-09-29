import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:projectschedule/controller/models_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MiddlePage extends StatefulWidget {
  const MiddlePage({Key? key}) : super(key: key);
  static final routeName = '/middlePage';

  @override
  _MiddlePageState createState() => _MiddlePageState();
}

class _MiddlePageState extends State<MiddlePage> {
  final ModelsController controller = Get.find<ModelsController>();

  late String? middleTaskName;
  late double middleTaskPercent;
  late DateTime? middleTaskDateTime;
  late DateTime? middleTaskDeadline;
  late String? middleTaskDescription;
  TextEditingController textEditingController = TextEditingController();
  late int? daysLeft;
  late bool willDelete;
  late int middleTaskKey;

  bool isInitial = true;

  String _popupMenuSelectedValue = "";

  int? smallTaskListLength = 0;

  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if(isInitial) {
      middleTaskName = Get.arguments['middleTaskName'];
      middleTaskPercent = Get.arguments['middleTaskPercent'];
      middleTaskDateTime = Get.arguments['middleTaskDateTime'].toDate();
      middleTaskDeadline = Get.arguments['middleTaskDeadline'] == null
          ? Get.arguments['middleTaskDeadline'] : Get.arguments['middleTaskDeadline'].toDate();
      middleTaskDescription = Get.arguments['middleTaskDescription'];
      if(middleTaskDescription != null){
        textEditingController.text = middleTaskDescription!;
      }
      daysLeft = Get.arguments['daysLeft'];
      willDelete = Get.arguments['willDelete'];
      middleTaskKey = Get.arguments['middleTaskKey'];
      isInitial = false;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            //update part
            // await controller.middleTaskPercentUpdate(middleTask, middleTask.smallTaskList);
            // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
            // await controller.bigProjectTargetUpdate(bigProject);
            // await controller.bigProjectCompletedTimeUpdate(bigProject);
            //update part end

            Get.back(result: willDelete);
          },
        ),
        actions:[
          Theme(
            data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                    color: Colors.blue
                )
            ),
            child: PopupMenuButton(
              icon: Icon(Icons.menu, color: Colors.white,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Edit name", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Edit name",
                ),
                PopupMenuItem(
                  child: Text("Copy", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Copy",
                ),
                PopupMenuItem(
                  child: Text("Remove", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Remove this task",
                ),
              ],
              onSelected: (value) async {
                _popupMenuSelectedValue = value as String;

                //update part
                if(_popupMenuSelectedValue == "Edit name"){
                  middleTaskName = await controller.middleTaskNameEdit(context, middleTaskKey, _popupMenuSelectedValue, middleTaskName);
                }
                if(_popupMenuSelectedValue == "Copy"){
                  // await controller.middleTaskCopy(context, middleTask, middleTaskList, _popupMenuSelectedValue);
                }
                if(_popupMenuSelectedValue == "Remove this task"){
                  await controller.middleTaskDeleteCheck(context, middleTaskName, willDelete, _popupMenuSelectedValue);
                }
                //update part end

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
                            "Task",
                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        Text(
                            "${middleTaskName}",
                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 23),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        smallTaskListLength == 0 ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${middleTaskPercent.floor()}%",
                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 30),
                                ),
                              ],
                            ),
                            Container(
                              height: size.height*0.015,
                            ),
                            Slider(
                              value: middleTaskPercent,
                              onChanged: (newPercent) async {
                                //update part
                                middleTaskPercent = newPercent;
                                // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                // await controller.bigProjectTargetUpdate(bigProject);
                                // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                //update part end
                                setState(() {});
                              },
                              min: 0,
                              max: 100,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Color(0xFFF7F7F7),
                                  child: IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () async {
                                      //update part
                                      if(middleTaskPercent >= 1){
                                        middleTaskPercent = middleTaskPercent - 1;
                                      }
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      // await controller.bigProjectTargetUpdate(bigProject);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Color(0xFFF7F7F7),
                                  child: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () async {
                                      //update part
                                      if(middleTaskPercent <= 99){
                                        middleTaskPercent = middleTaskPercent + 1;
                                      }
                                      // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                      // await controller.bigProjectTargetUpdate(bigProject);
                                      // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                      //update part end
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ) :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularPercentIndicator(
                                radius: 100.0,
                                lineWidth: 7.5,
                                percent: middleTaskPercent/100,
                                center: Text(
                                  "${(middleTaskPercent).floor()}%",
                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 25),
                                ),
                                progressColor: Colors.blue
                            ),
                          ],
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
                                  "${middleTaskDateTime?.year}-"
                                  "${middleTaskDateTime?.month}-"
                                  "${middleTaskDateTime?.day}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium',
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  middleTaskDateTime = await controller.startMiddleTaskDateTimePickerUpdate(context, middleTaskKey, middleTaskDateTime, middleTaskDeadline);
                                  daysLeft = await controller.middleTaskDaysLeftUpdate(daysLeft, middleTaskKey, middleTaskDateTime, middleTaskDeadline);
                                  //update part end
                                  setState(() {});
                                },
                              ),
                            ),
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
                                child: middleTaskDeadline != null ? Text(
                                  "${middleTaskDeadline?.year}-"
                                  "${middleTaskDeadline?.month}-"
                                  "${middleTaskDeadline?.day}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium',
                                  ),
                                ) : Text(
                                  "No Deadline",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  middleTaskDeadline = await controller.deadlineMiddleTaskPickerUpdate(context, middleTaskKey, middleTaskDateTime, middleTaskDeadline);
                                  daysLeft = await controller.middleTaskDaysLeftUpdate(daysLeft, middleTaskKey, middleTaskDateTime, middleTaskDeadline);
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
                            middleTaskDeadline != null ?
                            DateTime(middleTaskDeadline!.year, middleTaskDeadline!.month, middleTaskDeadline!.day)
                                .difference(DateTime(middleTaskDateTime!.year, middleTaskDateTime!.month, middleTaskDateTime!.day)
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
                                width: size.width*0.75,
                                child: ListTile(
                                  title: middleTaskDescription != null ?
                                  Text("${middleTaskDescription}", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.black)) :
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'NotoSansCJKkrMedium'
                                    ),
                                  ),
                                  onTap: () async {
                                    //update part
                                    middleTaskDescription = await controller.middleTaskDescriptionUpdate(context, middleTaskKey, middleTaskDescription, textEditingController);
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
            StreamBuilder<QuerySnapshot>(
              stream: firestoreInstance.collection("smallTaskList").snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  smallTaskListLength = snapshot.data!.docs.length;
                  return Padding(
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.account_tree_outlined),
                                Container(
                                  width: size.width*0.03,
                                ),
                                Text(
                                  "SubTasks",
                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if(snapshot.data!.docs[index]['middleTaskKey'] == middleTaskKey){
                                return ListTile(
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: snapshot.data!.docs[index]['smallTaskPercent'] != 100 ?
                                                Icon(Icons.circle_outlined) : Icon(Icons.check_circle_outline),
                                                onPressed: () async {
                                                  //update part
                                                  if(snapshot.data!.docs[index]['smallTaskPercent'] == 100) {
                                                    firestoreInstance.collection('smallTaskList').doc('${index}').update({'smallTaskPercent': 0.0});
                                                  }
                                                  else {
                                                    firestoreInstance.collection('smallTaskList').doc('${index}').update({'smallTaskPercent': 100.0});
                                                  }
                                                  // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
                                                  // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                                  // await controller.bigProjectTargetUpdate(bigProject);
                                                  // await controller.bigProjectCompletedTimeUpdate(bigProject);
                                                  //update part end
                                                  setState(() {});
                                                },
                                              ),
                                              SizedBox(
                                                width: size.width*0.4,
                                                child: Text(
                                                  "${snapshot.data!.docs[index]['smallTaskName']}",
                                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                                  softWrap: true,
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
                                                      widthFactor: snapshot.data!.docs[index]['smallTaskPercent']/100,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text("${snapshot.data!.docs[index]['smallTaskPercent'].floor()}%",style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    bool result = await Get.toNamed(
                                        '/smallPage',
                                        arguments: {
                                          'middleTaskName' : middleTaskName,
                                          'smallTaskName' : snapshot.data!.docs[index]['smallTaskName'],
                                          'smallTaskPercent' : snapshot.data!.docs[index]['smallTaskPercent'],
                                          'smallTaskDateTime' : snapshot.data!.docs[index]['smallTaskDateTime'],
                                          'smallTaskDeadline' : snapshot.data!.docs[index]['smallTaskDeadline'],
                                          'smallTaskDescription' : snapshot.data!.docs[index]['smallTaskDescription'],
                                          'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                          'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                          'smallTaskKey' : snapshot.data!.docs[index]['smallTaskKey'],
                                        }
                                    );

                                    //update part
                                    // await controller.smallTaskDelete(result, smallTaskList, index);
                                    // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
                                    // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
                                    // await controller.bigProjectTargetUpdate(bigProject);
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
                          ),
                        ],
                      ),
                    ),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          //update part
          await controller.createNewSmallTask(context, smallTaskListLength, middleTaskKey);
          // await controller.middleTaskPercentUpdate(middleTask, middleTask.smallTaskList);
          // await controller.bigProjectPercentUpdate(bigProject, middleTaskList);
          // await controller.bigProjectTargetUpdate(bigProject);
          // await controller.bigProjectCompletedTimeUpdate(bigProject);
          //update part end
          setState(() { });
        },
      ),
    );
  }
}