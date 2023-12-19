import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:xchange_net/core/app_data.dart';
import 'package:xchange_net/src/view/screen/user/chat_screen.dart';
import 'package:xchange_net/src/controller/ad_controller.dart';
import 'package:xchange_net/src/view/screen/user/all_product_screen.dart';
import 'package:xchange_net/src/view/screen/user/favorite_screen.dart';
import 'package:xchange_net/src/view/screen/user/my_ads_screen.dart';
import 'package:xchange_net/src/view/screen/user/my_profile_screen.dart';

final AdController controller = Get.put(AdController());

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  static const List<Widget> screens = [
    AllProductScreen(),
    FavoriteScreen(),
    MyAdsScreen(),
    ChatScreen(),
    MyProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
            () {
          return BottomNavyBar(
            itemCornerRadius: 10,
            selectedIndex: controller.currentBottomNavItemIndex.value,
            items: AppData.bottomNavyBarItems
                .map((item) => BottomNavyBarItem(
                icon: item.icon,
                title: Text(item.title),
                activeColor: item.activeColor,
                inactiveColor: item.inActiveColor)) //BottomNavyBarItem
                .toList(),
            onItemSelected: controller.switchBetweenBottomNavigationItems,
          );  //BottomNavyBar
        },
      ),  //Obx
      body: Obx(() {
        return PageTransitionSwitcher(
          duration: const Duration(seconds: 1),
          transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: screens[controller.currentBottomNavItemIndex.value],
        ); //PageTransitionSwitcher
      }), //Obx
    );
  }
}
