import 'package:projectschedule/pages/main_page.dart';
import 'package:projectschedule/pages/big_page.dart';
import 'package:projectschedule/pages/middle_page.dart';
import 'package:projectschedule/pages/small_page.dart';
import 'package:get/get.dart';

List<GetPage> routes = [
  GetPage(
      name: MainPage.routeName,
      page: () => MainPage(),
      transition: Transition.rightToLeft
  ),
  GetPage(
      name: BigPage.routeName,
      page: () => BigPage(),
      transition: Transition.rightToLeft
  ),
  GetPage(
      name: MiddlePage.routeName,
      page: () => MiddlePage(),
      transition: Transition.rightToLeft
  ),
  GetPage(
      name: SmallPage.routeName,
      page: () => SmallPage(),
      transition: Transition.rightToLeft
  ),
];