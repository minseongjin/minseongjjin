import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectschedule/model/models.dart';
import 'package:projectschedule/pages/big_page.dart';
import 'package:projectschedule/util/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectschedule/db.dart';

class ModelsController extends GetxController {
  final firestoreInstance = FirebaseFirestore.instance;

  //main_page
  Future<BigProject?> createNewBigProject(BuildContext context, int? index) async {
    if(index == null) return null;

    String? result = await showInputDialog(
        context: context,
        titleText: "프로젝트의 이름을 정해주세요.",
        labelText: "프로젝트",
        validatorText: "프로젝트의 이름을 입력해주세요.",
    );
    if(result == null) return null;

    firestoreInstance.collection("bigProjectList").doc('${index}').set(
        {
          'bigProjectName': result,
          'bigProjectSortingNumber': index,
          'bigProjectPercent': 0.0,
          'bigProjectRegistrationDateTime': Timestamp.now(),
          'bigProjectDateTime': Timestamp.now(),
          'bigProjectDeadline': null,
          'bigProjectCompletedTime': null,
          'bigProjectDescription': null,
          'daysLeft': null,
          'target': null,
          'willDelete': false,
          'archive': false,
          'bigProjectKey': index,
        });
    update();
  }

  Future<bool?> bigProjectDelete(bool willDelete, int index) async {
    if(willDelete == false) return null;

    if(willDelete) {
      firestoreInstance.collection("bigProjectList").doc('${index}').delete();
    }

    willDelete = false;
    update();

    return willDelete;
  }

  //big_page
  Future<double?> bigProjectPercentUpdate(BigProject newBigProject, List<MiddleTask> newMiddleTaskList) async {
    if(newMiddleTaskList.isEmpty) return null;

    double totalPercent (List<MiddleTask> middleTaskList) {
      double total = 0;
      middleTaskList.forEach(
              (element) {
            total = total + element.middleTaskPercent;
          }
      );
      return total;
    }

    newBigProject.bigProjectPercent = (totalPercent(newMiddleTaskList)/newMiddleTaskList.length).floorToDouble();
    update();

    return newBigProject.bigProjectPercent;
  }

  Future<DateTime?> bigProjectCompletedTimeUpdate(BigProject newBigProject) async {
    if(newBigProject.bigProjectPercent != 100) return null;

    newBigProject.bigProjectCompletedTime = DateTime.now();
    update();

    return newBigProject.bigProjectCompletedTime;
  }

  Future<int?> bigProjectDaysLeftUpdate(int? daysLeft, int bigProjectKey, DateTime? bigProjectDateTime, DateTime? bigProjectDeadline) async {
    if(bigProjectDeadline == null) return null;

    int daysLeftCalculate (int left){
      int leftplus1 = 0;
      leftplus1 = left + 1;
      return leftplus1;
    }

    daysLeft = daysLeftCalculate(
        DateTime(bigProjectDeadline.year, bigProjectDeadline.month, bigProjectDeadline.day)
            .difference(DateTime(bigProjectDateTime!.year, bigProjectDateTime.month, bigProjectDateTime.day)
        ).inDays
    );

    firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
      'daysLeft': daysLeft,
    });

    update();

    return daysLeft;
  }

  Future<double?> bigProjectTargetUpdate(double? target, int bigProjectKey, double bigProjectPercent, DateTime? bigProjectDateTime, DateTime? bigProjectDeadline) async {
    if(bigProjectDeadline == null) return null;

    int daysLeftCalculate (int left){
      int leftplus1 = 0;
      leftplus1 = left + 1;
      return leftplus1;
    }

    target = double.parse(((100 - bigProjectPercent)/daysLeftCalculate(
        DateTime(bigProjectDeadline.year, bigProjectDeadline.month, bigProjectDeadline.day)
            .difference(DateTime(bigProjectDateTime!.year, bigProjectDateTime.month, bigProjectDateTime.day)
        ).inDays as int)).toStringAsFixed(2)
    );

    firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
      'target': target,
    });
    update();

    return target;
  }

  Future<DateTime?> startBigProjectDateTimePickerUpdate(BuildContext context, int bigProjectKey, DateTime? bigProjectDateTime, DateTime? bigProjectDeadline) async {
    DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );

    if(pickedStart != null){
      if(bigProjectDeadline == null){
        bigProjectDateTime = pickedStart;
      }
      else if(bigProjectDeadline != null){
        bigProjectDateTime = pickedStart;
        if((bigProjectDateTime.year as int) <= (bigProjectDeadline.year as int)){
          if((bigProjectDateTime.month as int) <= (bigProjectDeadline.month as int)){
            if((bigProjectDateTime.day as int) <= (bigProjectDeadline.day as int)){
              bigProjectDateTime = pickedStart;
            }
            else{
              bigProjectDateTime = bigProjectDeadline;
            }
          }
          else{
            bigProjectDateTime = bigProjectDeadline;
          }
        }
        else{
          bigProjectDateTime = bigProjectDeadline;
        }
      }
    }

    firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
      'bigProjectDateTime': Timestamp.fromDate(bigProjectDateTime!),
    });

    update();

    return bigProjectDateTime;
  }

  Future<DateTime?> deadlineBigProjectPickerUpdate(BuildContext context, int bigProjectKey, DateTime? bigProjectDateTime, DateTime? bigProjectDeadline) async {
    DateTime? pickedDeadline = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );


    if(pickedDeadline != null){
      bigProjectDeadline = pickedDeadline;
      if((bigProjectDateTime?.year as int) <= (bigProjectDeadline.year as int)){
        if((bigProjectDateTime?.month as int) <= (bigProjectDeadline.month as int)){
          if((bigProjectDateTime?.day as int) <= (bigProjectDeadline.day as int)){
            bigProjectDeadline = pickedDeadline;
          }
          else{
            bigProjectDeadline = bigProjectDateTime;
          }
        }
        else{
          bigProjectDeadline = bigProjectDateTime;
        }
      }
      else{
        bigProjectDeadline = bigProjectDateTime;
      }
    }

    if(bigProjectDeadline != null){
      firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
        'bigProjectDeadline': Timestamp.fromDate(bigProjectDeadline),
      });
    }

    update();

    return bigProjectDeadline;
  }

  Future<String?> bigProjectDescriptionUpdate(BuildContext context, int bigProjectKey, String? bigProjectDescription, TextEditingController controller) async {

    String? result = await showDescriptionDialog(
      context: context,
      titleText: "프로젝트의 설명을 정해주세요.",
      labelText: "설명",
      validatorText: "프로젝트 설명을 적어주세요.",
      controller: controller,
    );
    if(result == null){
      if(bigProjectDescription != null){
        controller.text = bigProjectDescription;
      }
      return bigProjectDescription;
    }

    firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
      'bigProjectDescription': result,
    });

    update();

    return result;
  }

  Future<Structure?> createNewMiddleTask(BuildContext context, int? index, int bigProjectKey) async {
    if(index == null) return null;

    String? result = await showInputDialog(
        context: context,
        titleText: "업무의 이름을 정해주세요.",
        labelText: "업무",
        validatorText: "업무의 이름을 입력해주세요."
    );
    if(result == null) return null;

    firestoreInstance.collection("middleTaskList").doc('${index}').set(
        {
          'middleTaskName': result,
          'middleTaskSortingNumber': index,
          'middleTaskPercent': 0.0,
          'middleTaskRegistrationDateTime': Timestamp.now(),
          'middleTaskDateTime': Timestamp.now(),
          'middleTaskDeadline': null,
          'middleTaskDescription': null,
          'daysLeft': null,
          'willDelete': false,
          'bigProjectKey' : bigProjectKey,
          'middleTaskKey': index,
        });
    update();
  }

  Future<String?> bigProjectNameEdit (BuildContext context, int bigProjectKey, String? value, String? bigProjectName) async {
    if(value != "Edit name") return null;

    if(value == "Edit name") {
      String? result = await showInputDialog(
          context: context,
          titleText: "프로젝트의 이름을 정해주세요.",
          labelText: "프로젝트",
          validatorText: "프로젝트의 이름을 입력해주세요."
      );
      if(result == null) return bigProjectName;
      bigProjectName = result;

      firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
        'bigProjectName': result,
      });
      update();

      return result;
    }
  }

  Future<BigProject?> bigProjectCopy (BuildContext context, BigProject newBigProject, String? value) async {
    if(value != "Copy") return null;

    if(value == "Copy"){
      bool? copyCheck = await showCopyDialog(
        context: context,
        titleText: newBigProject.bigProjectName,
      );
      if(copyCheck == null) return null;

      if(copyCheck == true){
        BigProject copyBigProject = newBigProject.cloneStructure();

        DB.bigProjectList.insert(0, copyBigProject);

        copyCheck = false;
      }

    }
    update();
  }
  Future<bool?> bigProjectDeleteCheck (BuildContext context, String? bigProjectName, bool willDelete, String? value) async {
    if(value != "Delete this project") return null;
    print(bigProjectName);
    if(bigProjectName == null) return null;

    if(value == "Delete this project") {
      bool? result = await showDeleteDialog(
        context: context,
        titleText: bigProjectName,
        willDelete: willDelete,
      );
      if(result == null) return null;

      willDelete = result;

      update();

      Get.back(result: willDelete);
    }
  }
  Future<bool?> bigProjectArchive (BuildContext context, int bigProjectKey, bool? archive, String? value) async {
    if(value != "Archive") return null;

    if(value == "Archive"){
      archive = true;
      firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
        'archive': true,
      });
      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(Icons.download_outlined),
            Text('Archived project'),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            archive = false;
            firestoreInstance.collection('bigProjectList').doc('${bigProjectKey}').update({
              'archive': false,
            });
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      update();

      return archive;
    }
  }

  Future<List<MiddleTask>?> middleTaskDelete(MiddleTask newMiddleTask, List<MiddleTask> newMiddleTaskList, int index) async {
    if(newMiddleTask.willDelete == false) return null;

    if(newMiddleTask.willDelete) {
      newMiddleTaskList.removeAt(index);
    }

    newMiddleTask.willDelete = false;

    return newMiddleTaskList;
  }

  //middle_page
  Future<double?> middleTaskPercentUpdate(MiddleTask newMiddleTask, List<SmallTask> newSmallTaskList) async {
    if(newSmallTaskList.isEmpty) return null;

    double totalPercent (List<SmallTask> smallTaskList) {
      double total = 0;
      smallTaskList.forEach(
              (element) {
            total = total + element.smallTaskPercent;
          }
      );
      return total;
    }

    newMiddleTask.middleTaskPercent = (totalPercent(newSmallTaskList)/newSmallTaskList.length).floorToDouble();
    newMiddleTask.circularPercentIndicatorValue = newMiddleTask.middleTaskPercent/100;

    update();

    return newMiddleTask.middleTaskPercent;
  }

  Future<int?> middleTaskDaysLeftUpdate(int? daysLeft, int middleTaskKey, DateTime? middleTaskDateTime, DateTime? middleTaskDeadline) async {
    if(middleTaskDeadline == null) return null;

    int daysLeftCalculate (int left){
      int leftplus1 = 0;
      leftplus1 = left + 1;
      return leftplus1;
    }

    daysLeft = daysLeftCalculate(
        DateTime(middleTaskDeadline.year, middleTaskDeadline.month, middleTaskDeadline.day)
            .difference(DateTime(middleTaskDateTime!.year, middleTaskDateTime.month, middleTaskDateTime.day)
        ).inDays
    );

    firestoreInstance.collection('middleTaskList').doc('${middleTaskKey}').update({
      'daysLeft': daysLeft,
    });
    update();

    return daysLeft;
  }

  Future<String?> middleTaskNameEdit (BuildContext context, int middleTaskKey, String? value, String? middleTaskName) async {
    if(value != "Edit name") return null;

    if(value == "Edit name") {
      String? result = await showInputDialog(
          context: context,
          titleText: "업무의 이름을 정해주세요.",
          labelText: "업무",
          validatorText: "업무의 이름을 입력해주세요."
      );

      if(result == null) return null;
      middleTaskName = result;

      firestoreInstance.collection('middleTaskList').doc('${middleTaskKey}').update({
        'middleTaskName': result,
      });

      update();

      return middleTaskName;
    }
  }

  Future<MiddleTask?> middleTaskCopy (BuildContext context, MiddleTask newMiddleTask, List<MiddleTask> newMiddleTaskList, String? value) async {
    if(value != "Copy") return null;

    if(value == "Copy"){
      bool? copyCheck = await showCopyDialog(
        context: context,
        titleText: newMiddleTask.middleTaskName,
      );
      if(copyCheck == null) return null;

      if(copyCheck == true){
        MiddleTask copyMiddleTask = newMiddleTask.cloneStructure();

        newMiddleTaskList.add(copyMiddleTask);

        copyCheck = false;
      }

    }
    update();
  }
  //수정 필요 update part!!!
  Future<bool?> middleTaskDeleteCheck (BuildContext context, String? middleTaskName, bool willDelete, String? value) async {
    if(value != "Remove this task") return null;

    if(value == "Remove this task") {
      bool? result = await showDeleteDialog(
        context: context,
        titleText: middleTaskName!,
        willDelete: willDelete,
      );
      if(result == null) return null;

      willDelete = result;

      // double totalPercent (List<MiddleTask> middleTaskList) {
      //   double total = 0;
      //   middleTaskList.forEach(
      //           (element) {
      //         total = total + element.middleTaskPercent;
      //       }
      //   );
      //   return total;
      // }

      //update part
      // if(result == true&&newBigProject.middleTaskList.isNotEmpty){
      //   newBigProject.bigProjectPercent = (totalPercent(newBigProject.middleTaskList)-newMiddleTask.middleTaskPercent)/
      //       (newBigProject.middleTaskList.length == 1 ? 1 : (newBigProject.middleTaskList.length-1)).floorToDouble();
      // }
      //update part end

      update();

      Get.back(result: willDelete);
    }
  }
  Future<DateTime?> startMiddleTaskDateTimePickerUpdate(BuildContext context, int middleTaskKey, DateTime? middleTaskDateTime, DateTime? middleTaskDeadline) async {
    DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );


    if(pickedStart != null){
      if(middleTaskDeadline == null){
        middleTaskDateTime = pickedStart;
      }
      else if(middleTaskDeadline != null){
        middleTaskDateTime = pickedStart;
        if((middleTaskDateTime.year as int) <= (middleTaskDeadline.year as int)){
          if((middleTaskDateTime.month as int) <= (middleTaskDeadline.month as int)){
            if((middleTaskDateTime.day as int) <= (middleTaskDeadline.day as int)){
              middleTaskDateTime = pickedStart;
            }
            else{
              middleTaskDateTime = middleTaskDeadline;
            }
          }
          else{
            middleTaskDateTime = middleTaskDeadline;
          }
        }
        else{
          middleTaskDateTime = middleTaskDeadline;
        }
      }
    }

    firestoreInstance.collection('middleTaskList').doc('${middleTaskKey}').update({
      'middleTaskDateTime': Timestamp.fromDate(middleTaskDateTime!),
    });

    update();

    return middleTaskDateTime;
  }

  Future<DateTime?> deadlineMiddleTaskPickerUpdate(BuildContext context, int middleTaskKey, DateTime? middleTaskDateTime, DateTime? middleTaskDeadline) async {
    DateTime? pickedDeadline = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );

    if(pickedDeadline != null){
      middleTaskDeadline = pickedDeadline;
      if((middleTaskDateTime?.year as int) <= (middleTaskDeadline.year as int)){
        if((middleTaskDateTime?.month as int) <= (middleTaskDeadline.month as int)){
          if((middleTaskDateTime?.day as int) <= (middleTaskDeadline.day as int)){
            middleTaskDeadline = pickedDeadline;
          }
          else{
            middleTaskDeadline = middleTaskDateTime;
          }
        }
        else{
          middleTaskDeadline = middleTaskDateTime;
        }
      }
      else{
        middleTaskDeadline = middleTaskDateTime;
      }
    }

    if(middleTaskDeadline != null){
      firestoreInstance.collection('middleTaskList').doc('${middleTaskKey}').update({
        'middleTaskDeadline': Timestamp.fromDate(middleTaskDeadline),
      });
    }

    update();

    return middleTaskDeadline;
  }
  Future<String?> middleTaskDescriptionUpdate(BuildContext context, int middleTaskKey, String? middleTaskDescription, TextEditingController controller) async {
    String? result = await showDescriptionDialog(
      context: context,
      titleText: "업무의 설명을 정해주세요.",
      labelText: "설명",
      validatorText: "업무 설명을 적어주세요.",
      controller: controller,
    );
    if(result == null){
      if(middleTaskDescription != null){
        controller.text = middleTaskDescription;
      }
      return middleTaskDescription;
    }
    firestoreInstance.collection('middleTaskList').doc('${middleTaskKey}').update({
      'middleTaskDescription': result,
    });

    return result;
  }
  Future<List<SmallTask>?> smallTaskDelete(SmallTask newSmallTask, List<SmallTask> newSmallTaskList, int index) async {
    if(newSmallTask.willDelete == false) return null;

    if(newSmallTask.willDelete) {
      newSmallTaskList.removeAt(index);
    }

    newSmallTask.willDelete = false;

    return newSmallTaskList;
  }
  Future<SmallTask?> createNewSmallTask(BuildContext context, int? index, int middleTaskKey) async {
    String? result = await showInputDialog(
        context: context,
        titleText: "부분 업무의 이름을 정해주세요.",
        labelText: "부분 업무",
        validatorText: "부분 업무의 이름을 입력해주세요."
    );
    if(result == null) return null;

    firestoreInstance.collection("smallTaskList").doc('${index}').set(
        {
          'smallTaskName': result,
          'smallTaskPercent': 0.0,
          'smallTaskDateTime': Timestamp.now(),
          'smallTaskDeadline': null,
          'smallTaskDescription': null,
          'daysLeft': null,
          'willDelete': false,
          'middleTaskKey' : middleTaskKey,
          'smallTaskKey': index,
        });
    update();
  }

  //small_page
  Future<int?> smallTaskDaysLeftUpdate(int? daysLeft, int smallTaskKey, DateTime? smallTaskDateTime, DateTime? smallTaskDeadline) async {
    if(smallTaskDeadline == null) return null;

    int daysLeftCalculate (int left){
      int leftplus1 = 0;
      leftplus1 = left + 1;
      return leftplus1;
    }

    daysLeft = daysLeftCalculate(
        DateTime(smallTaskDeadline.year, smallTaskDeadline.month, smallTaskDeadline.day)
            .difference(DateTime(smallTaskDateTime!.year, smallTaskDateTime.month, smallTaskDateTime.day)
        ).inDays
    );

    firestoreInstance.collection('smallTaskList').doc('${smallTaskKey}').update({
      'daysLeft': daysLeft,
    });
    update();

    return daysLeft;
  }
  Future<String?> smallTaskNameEdit (BuildContext context, int smallTaskKey, String? value, String? smallTaskName) async {
    if(value != "Edit name") return null;

    if(value == "Edit name") {
      String? result = await showInputDialog(
          context: context,
          titleText: "부분 업무의 이름을 정해주세요.",
          labelText: "부분 업무",
          validatorText: "부분 업무의 이름을 입력해주세요."
      );
      if(result == null) return null;
      smallTaskName = result;

      firestoreInstance.collection('smallTaskList').doc('${smallTaskKey}').update({
        'smallTaskName': result,
      });

      update();

      return result;
    }
  }

  Future<SmallTask?> smallTaskCopy (BuildContext context, SmallTask newSmallTask, List<SmallTask> newSmallTaskList, String? value) async {
    if(value != "Copy") return null;

    if(value == "Copy"){
      bool? copyCheck = await showCopyDialog(
        context: context,
        titleText: newSmallTask.smallTaskName,
      );
      if(copyCheck == null) return null;

      if(copyCheck == true){
        SmallTask copySmallTask = newSmallTask.cloneStructure();

        newSmallTaskList.add(copySmallTask);

        copyCheck = false;
      }

    }
    update();
  }
  Future<bool?> smallTaskDeleteCheck (BuildContext context, String? smallTaskName, bool willDelete, String? value) async {
    if(value != "Remove this subtask") return null;

    if(value == "Remove this subtask") {
      bool? result = await showDeleteDialog(
        context: context,
        titleText: smallTaskName!,
        willDelete: willDelete,
      );
      if(result == null) return null;

      willDelete = result;

      // double totalPercent (List<SmallTask> smallTaskList) {
      //   double total = 0;
      //   smallTaskList.forEach(
      //           (element) {
      //         total = total + element.smallTaskPercent;
      //       }
      //   );
      //   return total;
      // }

      //update part
      // if(result == true&&newMiddleTask.smallTaskList.isNotEmpty){
      //   newMiddleTask.middleTaskPercent = (totalPercent(newMiddleTask.smallTaskList)-newSmallTask.smallTaskPercent)/
      //       (newMiddleTask.smallTaskList.length == 1 ? 1 : (newMiddleTask.smallTaskList.length-1)).floorToDouble();
      // }
      //update part end

      update();

      Get.back(result: willDelete);
    }
  }
  Future<DateTime?> startSmallTaskDateTimePickerUpdate(BuildContext context, int smallTaskKey, DateTime? smallTaskDateTime, DateTime? smallTaskDeadline) async {
    DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );


    if(pickedStart != null){
      if(smallTaskDeadline == null){
        smallTaskDateTime = pickedStart;
      }
      else if(smallTaskDeadline != null){
        smallTaskDateTime = pickedStart;
        if((smallTaskDateTime.year as int) <= (smallTaskDeadline.year as int)){
          if((smallTaskDateTime.month as int) <= (smallTaskDeadline.month as int)){
            if((smallTaskDateTime.day as int) <= (smallTaskDeadline.day as int)){
              smallTaskDateTime = pickedStart;
            }
            else{
              smallTaskDateTime = smallTaskDeadline;
            }
          }
          else{
            smallTaskDateTime = smallTaskDeadline;
          }
        }
        else{
          smallTaskDateTime = smallTaskDeadline;
        }
      }
    }

    firestoreInstance.collection('smallTaskList').doc('${smallTaskKey}').update({
      'smallTaskDateTime': Timestamp.fromDate(smallTaskDateTime!),
    });

    update();

    return smallTaskDateTime;
  }

  Future<DateTime?> deadlineSmallTaskPickerUpdate(BuildContext context, int smallTaskKey, DateTime? smallTaskDateTime, DateTime? smallTaskDeadline) async {
    DateTime? pickedDeadline = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );},
    );


    if(pickedDeadline != null){
      smallTaskDeadline = pickedDeadline;
      if((smallTaskDateTime?.year as int) <= (smallTaskDeadline.year as int)){
        if((smallTaskDateTime?.month as int) <= (smallTaskDeadline.month as int)){
          if((smallTaskDateTime?.day as int) <= (smallTaskDeadline.day as int)){
            smallTaskDeadline = pickedDeadline;
          }
          else{
            smallTaskDeadline = smallTaskDateTime;
          }
        }
        else{
          smallTaskDeadline = smallTaskDateTime;
        }
      }
      else{
        smallTaskDeadline = smallTaskDateTime;
      }
    }

    if(smallTaskDeadline != null){
      firestoreInstance.collection('smallTaskList').doc('${smallTaskKey}').update({
        'smallTaskDeadline': Timestamp.fromDate(smallTaskDeadline),
      });
    }

    update();

    return smallTaskDeadline;
  }

  Future<String?> smallTaskDescriptionUpdate(BuildContext context, int smallTaskKey, String? smallTaskDescription, TextEditingController controller) async {
    String? result = await showDescriptionDialog(
      context: context,
      titleText: "부분 업무의 설명을 정해주세요.",
      labelText: "설명",
      validatorText: "부분 업무 설명을 적어주세요.",
      controller: controller,
    );
    if(result == null){
      if(smallTaskDescription != null){
        controller.text = smallTaskDescription;
      }
      return smallTaskDescription;
    }
    firestoreInstance.collection('smallTaskList').doc('${smallTaskKey}').update({
      'smallTaskDescription': result,
    });

    return result;
  }
}