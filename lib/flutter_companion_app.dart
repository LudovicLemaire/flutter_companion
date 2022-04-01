import 'package:flutter/material.dart';
import 'package:flutter_compagnion/active_users_listview.dart';
import 'strings.dart' as strings;
import 'bottom_menu.dart';
import 'active_users_listview.dart';
import 'Search_users_view.dart';

class FlutterCompanionApp extends StatefulWidget {
  const FlutterCompanionApp({Key? key}) : super(key: key);

  @override
  _FlutterCompanionAppState createState() => _FlutterCompanionAppState();
}

class _FlutterCompanionAppState extends State<FlutterCompanionApp> {
  int _selectedIndexParent = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexParent = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const SearchUsersView(),
      const ActiveUsersListView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(strings.appTitle),
        backgroundColor: const Color(0xFF7289da),
      ),
      body: IndexedStack(
        index: _selectedIndexParent,
        children: pages,
      ),
      bottomNavigationBar: BottomMenu(
        selectedIndex: _onItemTapped,
      ),
    );
  }
}
