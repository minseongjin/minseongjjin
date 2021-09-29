import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<String?> showInputDialog({
  required BuildContext context,
  required String titleText,
  required String labelText,
  required String validatorText,
  String cancelText = "CANCEL",
  String okText = "OK",
}) async {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController controller = TextEditingController();

  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text(titleText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: false,
            decoration: InputDecoration(labelText: labelText, labelStyle: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
            validator: (value) => (value!.isEmpty) ? validatorText : null,
            maxLines: null,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(cancelText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: Text(okText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                onPressed: () {
                  if(!formKey.currentState!.validate()) return;
                  String result = controller.text;
                  Get.back(result: result);
                },
              ),
            ],
          )
        ],
      );
    }
  );
}

Future<String?> showDescriptionDialog({
  required BuildContext context,
  required String titleText,
  required String labelText,
  required String validatorText,
  String cancelText = "CANCEL",
  String okText = "OK",
  required TextEditingController? controller,
}) async {
  final GlobalKey<FormState> formKey = GlobalKey();

  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(titleText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              obscureText: false,
              decoration: InputDecoration(labelText: labelText, labelStyle: TextStyle(fontFamily: 'NotoSansCJKkrMedium')),
              validator: (value) => (value!.isEmpty) ? validatorText : null,
              maxLines: null,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(cancelText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  child: Text(okText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    if(!formKey.currentState!.validate()) return;
                    String result = controller!.text;
                    Get.back(result: result);
                  },
                ),
              ],
            )
          ],
        );
      }
  );
}

Future<bool?> showDeleteDialog({
  required BuildContext context,
  required String titleText,
  String cancelText = "CANCEL",
  String okText = "OK",
  required bool willDelete,
}) async {

  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.dangerous_rounded),
              Container(
                width: size.width*0.025,
              ),
              SizedBox(
                width: size.width*0.5,
                child: Text(
                    titleText,
                    style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),
                  softWrap: true,
                  maxLines: null,
                ),
              ),
            ],
          ),
          content: Text("Are you sure you want to delete?", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(cancelText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  child: Text(okText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    willDelete = true;
                    Get.back(result: willDelete);
                  },
                ),
              ],
            )
          ],
        );
      }
  );
}

Future<bool?> showCopyDialog({
  required BuildContext context,
  required String titleText,
  String cancelText = "CANCEL",
  String okText = "OK",
}) async {

  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("복사", style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'),),
          content: Text("'${titleText}'를 복사하시겠습니까?",  style: TextStyle(fontFamily: 'NotoSansCJKkrMedium'), softWrap: true, maxLines: null,),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(cancelText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  child: Text(okText, style: TextStyle(fontFamily: 'NotoSansCJKkrMedium', color: Colors.deepPurpleAccent)),
                  onPressed: () {
                    Get.back(result: true);
                  },
                ),
              ],
            )
          ],
        );
      }
  );
}

