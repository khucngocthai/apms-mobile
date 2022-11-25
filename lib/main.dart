// @dart=2.9

import 'package:apms_mobile/bloc/repositories/sign_up_repo.dart';
import 'package:apms_mobile/bloc/repositories/ticket_repo.dart';
import 'package:apms_mobile/bloc/sign_up_bloc.dart';
import 'package:apms_mobile/bloc/ticket_bloc.dart';
import 'package:apms_mobile/presentation/screens/history/history_tab.dart';
import 'package:apms_mobile/presentation/screens/home/home.dart';
import 'package:apms_mobile/presentation/screens/authen/sign_in.dart';
import 'package:apms_mobile/presentation/screens/profile/profile.dart';
import 'package:apms_mobile/themes/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SignUpBloc(SignUpRepo()),
          ),
        ],
        child: Builder(builder: (context) {
          return const SignIn();
        }),
      ),
    ),
  );
}

class MyHome extends StatefulWidget {
  final int tabIndex;
  final int headerTabIndex;
  const MyHome({Key key, this.tabIndex, this.headerTabIndex = 0})
      : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  PersistentTabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.jumpToTab(widget.tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: "Inter"),
        home: Scaffold(
          body: PersistentTabView(
            context,
            controller: _controller,
            screens: screens(),
            items: navBarItems(),
          ),
        ));
  }

  List<Widget> screens() {
    return [
      const Home(),
      History(
        selectedTab: widget.headerTabIndex,
      ),
      const Profile(),
    ];
  }

  List<PersistentBottomNavBarItem> navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        title: "History",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: systemGrey,
      ),
    ];
  }
}
