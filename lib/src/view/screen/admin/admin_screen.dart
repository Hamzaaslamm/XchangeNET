// import 'package:flutter/material.dart';
//
// class AdminScreen extends StatefulWidget {
//   @override
//   State<AdminScreen> createState() => _AdminScreenState();
// }
//
// class _AdminScreenState extends State<AdminScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to chat feature
//                 Navigator.pushNamed(context, '/chat');
//               },
//               child: Text('Chat'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to user management feature
//                 Navigator.pushNamed(context, '/user_management');
//               },
//               child: Text('Manage Users'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to promotion feature
//                 Navigator.pushNamed(context, '/promotion');
//               },
//               child: Text('Promotion'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Perform logout
//                 // You can implement your logout logic here
//               },
//               child: Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:xchange_net/src/view/screen/admin/promotion_screen.dart';
import 'package:xchange_net/src/view/screen/admin/suspend_user_screen.dart';
import '../../../../core/app_theme_admin.dart';
import '../../../../custom_drawer/drawer_user_controller.dart';
import '../../../../custom_drawer/home_drawer.dart';
import 'admin_chat_screen.dart';
import 'block_user_screen.dart';
import 'admin_dashboard_screen.dart';
import 'complain_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const AdminDashboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeAdmin.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppThemeAdmin.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const AdminDashboard();
          });
          break;
        case DrawerIndex.Chat:
          setState(() {
            screenView = AdminChatScreen();
          });
          break;
        case DrawerIndex.Promotion:
          setState(() {
            screenView = PromotionScreen();
          });
          break;
        case DrawerIndex.Block:
          setState(() {
            screenView = BlockUserScreen();
          });
          break;
        case DrawerIndex.Suspend:
          setState(() {
            screenView = SuspendUserScreen();
          });
          break;
        case DrawerIndex.Complain:
          setState(() {
            screenView = ComplainScreen();
          });
          break;
        default:
          break;
      }
    }
  }
}
