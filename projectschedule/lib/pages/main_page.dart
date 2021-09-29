import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectschedule/controller/models_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {

  const MainPage({Key? key}) : super(key: key);
  static final routeName = '/mainPage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final List<String> _mainPageDropdownValueList = [
    'All projects', 'Incomplete only', 'Completed only', 'Archived'
  ];
  String _dropdownSelectedValue = 'All projects';

  String _popupMenuSelectedValue = "";

  int? bigProjectListLength = null;

  final firestoreInstance = FirebaseFirestore.instance;

  List<DocumentSnapshot>? _docs;

  Future? _saving;

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ModelsController());
    final ModelsController controller = Get.find<ModelsController>();

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _dropdownSelectedValue,
          icon: const Icon(Icons.arrow_drop_down_outlined, color: Colors.white,),
          iconSize: 30,
          elevation: 16,
          dropdownColor: Colors.blue,
          underline: Container(
            height: 2,
            color: Colors.blue,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _dropdownSelectedValue = newValue!;
            });
          },
          items: _mainPageDropdownValueList.map<DropdownMenuItem<String>>((String value){
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value, style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),
              ),
            );
          }).toList(),
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
              elevation: 16,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text("Custom Order", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium'),),
                  value: "Custom Order",
                ),
                const PopupMenuItem(
                  child: Text("Registration Order", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Registration Order",
                ),
                const PopupMenuItem(
                  child: Text("Oldest First", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Oldest First",
                ),
                const PopupMenuItem(
                  child: Text("Achievement Order", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Achievement Order",
                ),
                const PopupMenuItem(
                  child: Text("Deadline Order", style: TextStyle(color: Colors.white, fontFamily: 'NotoSansCJKkrMedium')),
                  value: "Deadline Order",
                ),
              ],
              onSelected: (value) async {
                _popupMenuSelectedValue = value as String;
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _popupMenuSelectedValue == "Custom Order" ? StreamBuilder<QuerySnapshot>(
              stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectSortingNumber', descending: false).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  bigProjectListLength = snapshot.data!.docs.length;
                  _docs = snapshot.data!.docs;
                  return ReorderableListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if(snapshot.data!.docs.length != 0){
                        if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else{
                          return Container(
                            key: Key('$index'),
                          );
                        }
                      }
                      else{
                        return Container(
                          key: Key('$index'),
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
                          futures.add(_docs![pos].reference.update({'bigProjectSortingNumber': pos}));
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
            _popupMenuSelectedValue == "Registration Order" ? StreamBuilder<QuerySnapshot>(
              stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectRegistrationDateTime', descending: true).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  bigProjectListLength = snapshot.data!.docs.length;
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          key: Key('$index'),
                          margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                      ),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                      Text(
                                          "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                      ) :
                                      Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                          Icon(Icons.folder_outlined, size: 27,) :
                                          Stack(
                                            children: [
                                              Icon(Icons.folder_outlined, size: 27,),
                                              Icon(Icons.check, size: 27,)
                                            ],
                                          ),
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          SizedBox(
                                            width: size.width*0.4,
                                            child: Text(
                                              "${snapshot.data!.docs[index]['bigProjectName']}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                  widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                      snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: 오늘 마감",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Text(""),
                                    ],
                                  ) :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Completed!",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              bool result = await Get.toNamed(
                                  '/bigPage',
                                  arguments: {
                                    'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                    'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                    'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                    'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                    'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                    'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                    'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                    'target' : snapshot.data!.docs[index]['target'],
                                    'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                    'archive' : snapshot.data!.docs[index]['archive'],
                                    'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                  }
                              );

                              //update part
                              controller.bigProjectDelete(result, index);
                              //update part end

                              setState(() {});
                            },
                          ),
                        );
                      }
                      else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          key: Key('$index'),
                          margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                      ),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                      Text(
                                          "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                      ) :
                                      Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                          Icon(Icons.folder_outlined, size: 27,) :
                                          Stack(
                                            children: [
                                              Icon(Icons.folder_outlined, size: 27,),
                                              Icon(Icons.check, size: 27,)
                                            ],
                                          ),
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          SizedBox(
                                            width: size.width*0.4,
                                            child: Text(
                                              "${snapshot.data!.docs[index]['bigProjectName']}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                  widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                      snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: 오늘 마감",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Text(""),
                                    ],
                                  ) :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Completed!",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              bool result = await Get.toNamed(
                                  '/bigPage',
                                  arguments: {
                                    'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                    'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                    'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                    'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                    'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                    'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                    'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                    'target' : snapshot.data!.docs[index]['target'],
                                    'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                    'archive' : snapshot.data!.docs[index]['archive'],
                                    'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                  }
                              );

                              //update part
                              controller.bigProjectDelete(result, index);
                              //update part end

                              setState(() {});
                            },
                          ),
                        );
                      }
                      else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          key: Key('$index'),
                          margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                      ),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                      Text(
                                          "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                      ) :
                                      Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                          Icon(Icons.folder_outlined, size: 27,) :
                                          Stack(
                                            children: [
                                              Icon(Icons.folder_outlined, size: 27,),
                                              Icon(Icons.check, size: 27,)
                                            ],
                                          ),
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          SizedBox(
                                            width: size.width*0.4,
                                            child: Text(
                                              "${snapshot.data!.docs[index]['bigProjectName']}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                  widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                      snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: 오늘 마감",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Text(""),
                                    ],
                                  ) :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Completed!",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              bool result = await Get.toNamed(
                                  '/bigPage',
                                  arguments: {
                                    'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                    'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                    'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                    'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                    'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                    'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                    'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                    'target' : snapshot.data!.docs[index]['target'],
                                    'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                    'archive' : snapshot.data!.docs[index]['archive'],
                                    'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                  }
                              );

                              //update part
                              controller.bigProjectDelete(result, index);
                              //update part end

                              setState(() {});
                            },
                          ),
                        );
                      }
                      else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          key: Key('$index'),
                          margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                      ),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                      SizedBox(
                                        width: size.width*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                      Text(
                                          "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                      ) :
                                      Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                          Icon(Icons.folder_outlined, size: 27,) :
                                          Stack(
                                            children: [
                                              Icon(Icons.folder_outlined, size: 27,),
                                              Icon(Icons.check, size: 27,)
                                            ],
                                          ),
                                          Container(
                                            width: size.width*0.03,
                                          ),
                                          SizedBox(
                                            width: size.width*0.4,
                                            child: Text(
                                              "${snapshot.data!.docs[index]['bigProjectName']}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                  widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: size.height*0.015,
                                  ),
                                  snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                      snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: 오늘 마감",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Row(
                                        children: [
                                          Text(
                                            "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                          SizedBox(
                                            width: size.width*0.03,
                                          ),
                                          Text(
                                            "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                          ),
                                        ],
                                      ) :
                                      Text(""),
                                    ],
                                  ) :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Completed!",
                                        style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              bool result = await Get.toNamed(
                                  '/bigPage',
                                  arguments: {
                                    'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                    'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                    'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                    'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                    'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                    'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                    'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                    'target' : snapshot.data!.docs[index]['target'],
                                    'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                    'archive' : snapshot.data!.docs[index]['archive'],
                                    'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                  }
                              );

                              //update part
                              controller.bigProjectDelete(result, index);
                              //update part end

                              setState(() {});
                            },
                          ),
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
            _popupMenuSelectedValue == "Oldest First" ? StreamBuilder<QuerySnapshot>(
                stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectRegistrationDateTime', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    bigProjectListLength = snapshot.data!.docs.length;
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
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
            _popupMenuSelectedValue == "Achievement Order" ? StreamBuilder<QuerySnapshot>(
                stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectCompletedTime', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    bigProjectListLength = snapshot.data!.docs.length;
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
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
            _popupMenuSelectedValue == "Deadline Order"? StreamBuilder<QuerySnapshot>(
                stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectDeadline', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    bigProjectListLength = snapshot.data!.docs.length;
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
                          );
                        }
                        else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: Key('$index'),
                            margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                              "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                        ),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                        SizedBox(
                                          width: size.width*0.015,
                                        ),
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                        Text(
                                            "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                        ) :
                                        Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                            Icon(Icons.folder_outlined, size: 27,) :
                                            Stack(
                                              children: [
                                                Icon(Icons.folder_outlined, size: 27,),
                                                Icon(Icons.check, size: 27,)
                                              ],
                                            ),
                                            Container(
                                              width: size.width*0.03,
                                            ),
                                            SizedBox(
                                              width: size.width*0.4,
                                              child: Text(
                                                "${snapshot.data!.docs[index]['bigProjectName']}",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                    widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: size.height*0.015,
                                    ),
                                    snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                        snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: 오늘 마감",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Row(
                                          children: [
                                            Text(
                                              "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                            SizedBox(
                                              width: size.width*0.03,
                                            ),
                                            Text(
                                              "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                            ),
                                          ],
                                        ) :
                                        Text(""),
                                      ],
                                    ) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Completed!",
                                          style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                bool result = await Get.toNamed(
                                    '/bigPage',
                                    arguments: {
                                      'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                      'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                      'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                      'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                      'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                      'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                      'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                      'target' : snapshot.data!.docs[index]['target'],
                                      'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                      'archive' : snapshot.data!.docs[index]['archive'],
                                      'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                    }
                                );

                                //update part
                                controller.bigProjectDelete(result, index);
                                //update part end

                                setState(() {});
                              },
                            ),
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
                stream: firestoreInstance.collection("bigProjectList").orderBy('bigProjectSortingNumber', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    bigProjectListLength = snapshot.data!.docs.length;
                    _docs = snapshot.data!.docs;
                    return ReorderableListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if(snapshot.data!.docs.length != 0){
                          if(_dropdownSelectedValue == 'All projects'&&snapshot.data!.docs[index]['archive'] == false){
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              key: Key('$index'),
                              margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                          ),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                          Text(
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                          ) :
                                          Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                              Icon(Icons.folder_outlined, size: 27,) :
                                              Stack(
                                                children: [
                                                  Icon(Icons.folder_outlined, size: 27,),
                                                  Icon(Icons.check, size: 27,)
                                                ],
                                              ),
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              SizedBox(
                                                width: size.width*0.4,
                                                child: Text(
                                                  "${snapshot.data!.docs[index]['bigProjectName']}",
                                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                      widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                          snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: 오늘 마감",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Text(""),
                                        ],
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Completed!",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  bool result = await Get.toNamed(
                                      '/bigPage',
                                      arguments: {
                                        'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                        'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                        'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                        'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                        'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                        'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                        'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                        'target' : snapshot.data!.docs[index]['target'],
                                        'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                        'archive' : snapshot.data!.docs[index]['archive'],
                                        'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                      }
                                  );

                                  //update part
                                  controller.bigProjectDelete(result, index);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            );
                          }
                          else if(_dropdownSelectedValue == 'Incomplete only'&&snapshot.data!.docs[index]['bigProjectPercent'] < 100){
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              key: Key('$index'),
                              margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                          ),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                          Text(
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                          ) :
                                          Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                              Icon(Icons.folder_outlined, size: 27,) :
                                              Stack(
                                                children: [
                                                  Icon(Icons.folder_outlined, size: 27,),
                                                  Icon(Icons.check, size: 27,)
                                                ],
                                              ),
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              SizedBox(
                                                width: size.width*0.4,
                                                child: Text(
                                                  "${snapshot.data!.docs[index]['bigProjectName']}",
                                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                      widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                          snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: 오늘 마감",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Text(""),
                                        ],
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Completed!",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  bool result = await Get.toNamed(
                                      '/bigPage',
                                      arguments: {
                                        'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                        'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                        'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                        'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                        'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                        'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                        'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                        'target' : snapshot.data!.docs[index]['target'],
                                        'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                        'archive' : snapshot.data!.docs[index]['archive'],
                                        'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                      }
                                  );

                                  //update part
                                  controller.bigProjectDelete(result, index);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            );
                          }
                          else if(_dropdownSelectedValue == 'Completed only'&&snapshot.data!.docs[index]['bigProjectPercent'] == 100){
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              key: Key('$index'),
                              margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                          ),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                          Text(
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                          ) :
                                          Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                              Icon(Icons.folder_outlined, size: 27,) :
                                              Stack(
                                                children: [
                                                  Icon(Icons.folder_outlined, size: 27,),
                                                  Icon(Icons.check, size: 27,)
                                                ],
                                              ),
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              SizedBox(
                                                width: size.width*0.4,
                                                child: Text(
                                                  "${snapshot.data!.docs[index]['bigProjectName']}",
                                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                      widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                          snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: 오늘 마감",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Text(""),
                                        ],
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Completed!",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  bool result = await Get.toNamed(
                                      '/bigPage',
                                      arguments: {
                                        'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                        'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                        'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                        'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                        'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                        'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                        'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                        'target' : snapshot.data!.docs[index]['target'],
                                        'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                        'archive' : snapshot.data!.docs[index]['archive'],
                                        'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                      }
                                  );

                                  //update part
                                  controller.bigProjectDelete(result, index);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            );
                          }
                          else if(_dropdownSelectedValue == 'Archived'&&snapshot.data!.docs[index]['archive'] == true){
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              key: Key('$index'),
                              margin: EdgeInsets.only(right: 10, left: 10, top: 7, bottom: 7),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().year}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().month}-"
                                                "${snapshot.data!.docs[index]['bigProjectDateTime'].toDate().day}",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',),
                                          ),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          Text("-", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
                                          SizedBox(
                                            width: size.width*0.015,
                                          ),
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null?
                                          Text(
                                              "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().year}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().month}-"
                                                  "${snapshot.data!.docs[index]['bigProjectDeadline'].toDate().day}",
                                              style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')
                                          ) :
                                          Text("No Deadline", style: TextStyle(color: Colors.redAccent, fontFamily: 'NotoSansCJKkrMedium'),),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                              Icon(Icons.folder_outlined, size: 27,) :
                                              Stack(
                                                children: [
                                                  Icon(Icons.folder_outlined, size: 27,),
                                                  Icon(Icons.check, size: 27,)
                                                ],
                                              ),
                                              Container(
                                                width: size.width*0.03,
                                              ),
                                              SizedBox(
                                                width: size.width*0.4,
                                                child: Text(
                                                  "${snapshot.data!.docs[index]['bigProjectName']}",
                                                  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', fontSize: 18),
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
                                                      widthFactor: snapshot.data!.docs[index]['bigProjectPercent']/100,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "${snapshot.data!.docs[index]['bigProjectPercent'].floor()}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: size.height*0.015,
                                      ),
                                      snapshot.data!.docs[index]['bigProjectPercent'] != 100 ?
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          snapshot.data!.docs[index]['bigProjectDeadline'] != null ?
                                          snapshot.data!.docs[index]['daysLeft'] == 1 ?
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: 오늘 마감",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Row(
                                            children: [
                                              Text(
                                                "남은 날짜: ${snapshot.data!.docs[index]['daysLeft']} 일",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                              SizedBox(
                                                width: size.width*0.03,
                                              ),
                                              Text(
                                                "남은 매일 목표량: ${snapshot.data!.docs[index]['target']}%",
                                                style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                                              ),
                                            ],
                                          ) :
                                          Text(""),
                                        ],
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Completed!",
                                            style: TextStyle(fontFamily: 'NotoSansCJKkrMedium',color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  bool result = await Get.toNamed(
                                      '/bigPage',
                                      arguments: {
                                        'bigProjectName' : snapshot.data!.docs[index]['bigProjectName'],
                                        'bigProjectPercent' : snapshot.data!.docs[index]['bigProjectPercent'],
                                        'bigProjectDateTime' : snapshot.data!.docs[index]['bigProjectDateTime'],
                                        'bigProjectDeadline' : snapshot.data!.docs[index]['bigProjectDeadline'],
                                        'bigProjectCompletedTime' : snapshot.data!.docs[index]['bigProjectCompletedTime'],
                                        'bigProjectDescription' : snapshot.data!.docs[index]['bigProjectDescription'],
                                        'daysLeft' : snapshot.data!.docs[index]['daysLeft'],
                                        'target' : snapshot.data!.docs[index]['target'],
                                        'willDelete' : snapshot.data!.docs[index]['willDelete'],
                                        'archive' : snapshot.data!.docs[index]['archive'],
                                        'bigProjectKey' : snapshot.data!.docs[index]['bigProjectKey'],
                                      }
                                  );

                                  //update part
                                  controller.bigProjectDelete(result, index);
                                  //update part end

                                  setState(() {});
                                },
                              ),
                            );
                          }
                          else{
                            return Container(
                              key: Key('$index'),
                            );
                          }
                        }
                        else{
                          return Container(
                            key: Key('$index'),
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
                            futures.add(_docs![pos].reference.update({'bigProjectSortingNumber': pos}));
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          //update part
          await controller.createNewBigProject(context, bigProjectListLength);
          // update part end

          setState(() {});
        },
      ),
      drawer: Drawer(

      ),
    );
  }
}