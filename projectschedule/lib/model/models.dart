import 'package:flutter/cupertino.dart';

class BigProject {
  String bigProjectName;
  double bigProjectPercent = 0;
  DateTime? bigProjectRegistrationDateTime = DateTime.now();
  DateTime? bigProjectDateTime = DateTime.now();
  DateTime? bigProjectDeadline = null;
  DateTime? bigProjectCompletedTime;
  String? bigProjectDescription;
  TextEditingController controller = TextEditingController();
  int? daysLeft;
  double? target;
  bool willDelete = false;
  bool archive = false;
  List<MiddleTask> middleTaskList = [];

  BigProject(this.bigProjectName);

  BigProject.clone(BigProject bigProject) : this(bigProject.bigProjectName);

  BigProject cloneStructure() {
    BigProject newProject = BigProject(bigProjectName);
    newProject.middleTaskList = middleTaskList.map(
            (middleTask) => middleTask.cloneStructure()
    ).toList();

    return newProject;
  }
}

class MiddleTask {
  String middleTaskName;
  double middleTaskPercent = 0;
  double circularPercentIndicatorValue = 0;
  DateTime? middleTaskRegistrationDateTime = DateTime.now();
  DateTime? middleTaskDateTime = DateTime.now();
  DateTime? middleTaskDeadline;
  String? middleTaskDescription;
  TextEditingController controller = TextEditingController();
  int? daysLeft;
  bool willDelete = false;
  List<SmallTask> smallTaskList = [];

  MiddleTask(this.middleTaskName);

  MiddleTask cloneStructure() {
    MiddleTask newMiddleTask = MiddleTask(middleTaskName);
    newMiddleTask.smallTaskList = smallTaskList.map(
            (smallTask) => smallTask.cloneStructure()
    ).toList();
    return newMiddleTask;
  }
}

class SmallTask {
  String smallTaskName;
  double smallTaskPercent = 0;
  DateTime? smallTaskRegistrationDateTime = DateTime.now();
  DateTime? smallTaskDateTime = DateTime.now();
  DateTime? smallTaskDeadline;
  String? smallTaskDescription;
  TextEditingController controller = TextEditingController();
  int? daysLeft;
  bool willDelete = false;
  List<SubSmallTask> subSmallTaskList = [];

  SmallTask(this.smallTaskName);

  SmallTask cloneStructure() {
    SmallTask newSmallTask = SmallTask(smallTaskName);

    return newSmallTask;
  }
}

class SubSmallTask {

}