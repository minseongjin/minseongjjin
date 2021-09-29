import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectschedule/controller/models_controller.dart';

class SmallPage extends StatefulWidget {
  const SmallPage({Key? key}) : super(key: key);
  static final routeName = '/smallPage';

  @override
  _SmallPageState createState() => _SmallPageState();
}

class _SmallPageState extends State<SmallPage> {
  final ModelsController controller = Get.find<ModelsController>();

  late String? middleTaskName;
  late String? smallTaskName;
  late double smallTaskPercent;
  late DateTime? smallTaskDateTime;
  late DateTime? smallTaskDeadline;
  late String? smallTaskDescription;
  TextEditingController textEditingController = TextEditingController();
  late int? daysLeft;
  late bool willDelete;
  late int smallTaskKey;

  bool isInitial = true;

  String _popupMenuSelectedValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if(isInitial) {
      middleTaskName = Get.arguments['middleTaskName'];
      smallTaskName = Get.arguments['smallTaskName'];
      smallTaskPercent = Get.arguments['smallTaskPercent'];
      smallTaskDateTime = Get.arguments['smallTaskDateTime'].toDate();
      smallTaskDeadline = Get.arguments['smallTaskDeadline'] == null
          ? Get.arguments['smallTaskDeadline'] : Get.arguments['smallTaskDeadline'].toDate();
      smallTaskDescription = Get.arguments['smallTaskDescription'];
      if(smallTaskDescription != null){
        textEditingController.text = smallTaskDescription!;
      }
      daysLeft = Get.arguments['daysLeft'];
      willDelete = Get.arguments['willDelete'];
      smallTaskKey = Get.arguments['smallTaskKey'];
      isInitial = false;
    }



    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            //update part
            // smallTask.smallTaskPercent = smallTask.smallTaskPercent.floorToDouble();
            // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
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
                  value: "Remove this subtask",
                ),
              ],
              onSelected: (value) async {
                _popupMenuSelectedValue = value as String;

                //update part
                if(_popupMenuSelectedValue == "Edit name"){
                  smallTaskName = await controller.smallTaskNameEdit(context, smallTaskKey, _popupMenuSelectedValue, smallTaskName);
                }
                if(_popupMenuSelectedValue == "Copy"){
                  // await controller.middleTaskCopy(context, middleTask, middleTaskList, _popupMenuSelectedValue);
                }
                if(_popupMenuSelectedValue == "Remove this task"){
                  await controller.smallTaskDeleteCheck(context, smallTaskName, willDelete, _popupMenuSelectedValue);
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
                            "${middleTaskName}",
                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        Text(
                            "${smallTaskName}",
                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 23),
                        ),
                        Container(
                          height: size.height*0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${smallTaskPercent.floor()}%",
                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 30),
                            ),
                          ],
                        ),
                        Container(
                          height: size.height*0.015,
                        ),
                        Slider(
                            value: smallTaskPercent,
                            onChanged: (newPercent) async {
                              //update part
                              smallTaskPercent = newPercent;
                              // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
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
                                  if(smallTaskPercent >= 1){
                                    smallTaskPercent = smallTaskPercent - 1;
                                  }
                                  // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
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
                                  if(smallTaskPercent <= 99){
                                    smallTaskPercent = smallTaskPercent + 1;
                                  }
                                  // await controller.middleTaskPercentUpdate(middleTask, smallTaskList);
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
                                  "${smallTaskDateTime?.year}-"
                                      "${smallTaskDateTime?.month}-"
                                      "${smallTaskDateTime?.day}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium'
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  smallTaskDateTime = await controller.startSmallTaskDateTimePickerUpdate(context, smallTaskKey, smallTaskDateTime, smallTaskDeadline);
                                  daysLeft = await controller.smallTaskDaysLeftUpdate(daysLeft, smallTaskKey, smallTaskDateTime, smallTaskDeadline);
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
                                child: smallTaskDeadline != null ? Text(
                                  "${smallTaskDeadline?.year}-"
                                      "${smallTaskDeadline?.month}-"
                                      "${smallTaskDeadline?.day}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium'
                                  ),
                                ) : Text(
                                  "No Deadline",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontFamily: 'NotoSansCJKkrMedium'
                                  ),
                                ),
                                onPressed: () async {
                                  //update part
                                  smallTaskDeadline = await controller.deadlineSmallTaskPickerUpdate(context, smallTaskKey, smallTaskDateTime, smallTaskDeadline);
                                  daysLeft = await controller.smallTaskDaysLeftUpdate(daysLeft, smallTaskKey, smallTaskDateTime, smallTaskDeadline);
                                  //update part end
                                  setState(() {});
                                }
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
                            smallTaskDeadline != null ?
                            DateTime(smallTaskDeadline!.year, smallTaskDeadline!.month, smallTaskDeadline!.day)
                                .difference(DateTime(smallTaskDateTime!.year, smallTaskDateTime!.month, smallTaskDateTime!.day)
                            ).inDays == 0?
                            Text("남은 날짜: 오늘 마감", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),) :
                            Text("남은 날짜: ${daysLeft} 일", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),) :
                            Text("남은 날짜: -", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
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
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Color(0xFFF7F7F7),
                              child: SizedBox(
                                width: size.width*0.75,
                                child: ListTile(
                                  title: smallTaskDescription != null ?
                                  Text(
                                    "${smallTaskDescription}",
                                    style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'NotoSansCJKkrMedium',
                                    ),
                                  ) :
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                        color: Colors.black,
                                      fontFamily: 'NotoSansCJKkrMedium',
                                    ),
                                  ),
                                  onTap: () async {
                                    //update part
                                    smallTaskDescription = await controller.smallTaskDescriptionUpdate(context, smallTaskKey, smallTaskDescription, textEditingController);
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
            )
          ]
        )
      )
    );
  }
}