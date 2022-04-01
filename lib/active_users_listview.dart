import 'package:flutter/material.dart';
import 'package:flutter_compagnion/main.dart';
import 'package:provider/provider.dart';
import 'student.dart';
import 'get_token.dart';
import 'user_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const perPage = 10;

class ActiveUsersListView extends StatefulWidget {
  const ActiveUsersListView({Key? key}) : super(key: key);

  @override
  _ActiveUsersListView createState() => _ActiveUsersListView();
}

class _ActiveUsersListView extends State<ActiveUsersListView> {
  late ScrollController controller;
  final _users = <StudentReduce>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  int _page = 1;
  bool _gotAllUsers = false;
  bool _waitResponse = true;

  // String _token = "";

  void _incrementPage() {
    setState(() {
      ++_page;
    });
  }

  void _setGotAllUsers() {
    setState(() {
      _gotAllUsers = true;
    });
  }

  void _stopWaiting() {
    setState(() {
      _waitResponse = false;
    });
  }

  void _startWaiting() {
    setState(() {
      _waitResponse = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .editLoadingOverlay(true);
      await _getNextPage();
      Provider.of<GlobalViewModel>(context, listen: false)
          .editLoadingOverlay(false);
    });
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: controller,
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int position) {
          return _buildRow(position);
        },
        separatorBuilder: (context, index) {
          return const Divider();
        });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _buildRow(int i) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(_users[i].login, style: _biggerFont),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          backgroundImage: NetworkImage(_users[i].avatarUrl),
        ),
        subtitle: Text(_users[i].name),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserView(
                id: _users[i].id,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _getNextPage() async {
    var userList = await _getUsers(_page);
    if (userList.length != perPage) {
      _setGotAllUsers();
    }
    _incrementPage();
    if (userList.isNotEmpty) {
      setState(() {
        for (final item in userList) {
          final login = item['user']['login'] as String? ?? '';
          final name = item['user']['usual_full_name'] as String? ?? '';
          final avatarUrl = item['user']['image_url'] as String? ?? '';
          final staff = item['user']['staff?'] as bool? ?? false;
          final id = item['user']['id'] as int? ?? 0;
          final user = StudentReduce(login, name, avatarUrl, staff, id);
          _users.add(user);
        }
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    _stopWaiting();
    // print("page: " +
    //     (_page - 1).toString() +
    //     " - total: " +
    //     _users.length.toString());
  }

  Future<List> _getUsers(int page) async {
    String token = Provider.of<GlobalViewModel>(context, listen: false).token;
    List dataList = [];

    final responseUsers = await http.get(
        Uri.parse(
            'https://api.intra.42.fr/v2/campus/9/locations?filter[active]=true&filter[primary]=true&per_page=$perPage&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (responseUsers.statusCode != 200) {
      if (responseUsers.statusCode == 401) {
        getToken(context);
      }
      await Future.delayed(const Duration(seconds: 1));
      return _getUsers(page);
    } else {
      dataList = jsonDecode(responseUsers.body) as List;
    }
    return dataList;
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500 &&
        !_waitResponse &&
        !_gotAllUsers) {
      setState(() {
        _getNextPage();
        _startWaiting();
      });
    }
  }
}
