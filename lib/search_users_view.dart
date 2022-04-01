import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compagnion/main.dart';
import 'package:provider/provider.dart';
import 'student.dart';
import 'get_token.dart';
import 'user_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skeletons/skeletons.dart';

const perPage = 10;

class SearchUsersView extends StatefulWidget {
  const SearchUsersView({
    Key? key,
  }) : super(key: key);

  @override
  _SearchUsersView createState() => _SearchUsersView();
}

class _SearchUsersView extends State<SearchUsersView> {
  late ScrollController controller;
  var _users = <StudentReduce>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  int _page = 1;
  bool _gotAllUsers = false;
  bool _waitResponseScroll = true;
  String _name = '';
  bool _isSearching = false;

  void _setName(String newName) {
    setState(() {
      _name = newName;
    });
  }

  void _resetStudents() {
    setState(() {
      _users = <StudentReduce>[];
    });
  }

  void _resetPage() {
    setState(() {
      _page = 1;
    });
  }

  void _incrementPage() {
    setState(() {
      ++_page;
    });
  }

  void _resetGotAllUsers() {
    setState(() {
      _gotAllUsers = false;
    });
  }

  void _setGotAllUsers() {
    setState(() {
      _gotAllUsers = true;
    });
  }

  void _stopWaitingScroll() {
    setState(() {
      _waitResponseScroll = false;
    });
  }

  void _startWaitingScroll() {
    setState(() {
      _waitResponseScroll = true;
    });
  }

  void _setIsSearching(bool v) {
    setState(() {
      _isSearching = v;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  Timer searchOnStoppedTyping = Timer.periodic(Duration.zero, (timer) {});
  // ignore: unused_element
  _onChangeHandler(v) {
    const duration = Duration(milliseconds: 500);
    setState(() => searchOnStoppedTyping.cancel());
    setState(
        () => searchOnStoppedTyping = Timer(duration, () => searchStudents(v)));
  }

  searchStudents(String newName) {
    _setName(newName);
    _getNextPage(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(7),
          child: TextField(
            onSubmitted: searchStudents,
            //onChanged: _onChangeHandler,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search student',
            ),
          ),
        ),
        if (!_isSearching || _page != 1)
          Expanded(
            child: ListView.separated(
                controller: controller,
                itemCount: _users.length,
                itemBuilder: (BuildContext context, int position) {
                  return _studentList(position);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                }),
          ),
        if (_isSearching && _page == 1)
          Expanded(
            child: ListView.separated(
                controller: controller,
                itemCount: 5,
                itemBuilder: (BuildContext context, int position) {
                  return _studentSkeletonList(position);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                }),
          ),
      ],
    );
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _studentList(int i) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(_users[i].login, style: _biggerFont),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          backgroundImage: NetworkImage(_users[i].avatarUrl),
        ),
        subtitle: Text(_users[i].name),
        trailing: _users[i].staff
            ? const Icon(
                Icons.star,
                color: Color.fromARGB(255, 242, 196, 16),
                size: 25,
              )
            : const SizedBox.shrink(),
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

  Widget _studentSkeletonList(int i) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        title: SkeletonLine(
          style: SkeletonLineStyle(
              height: 10,
              minLength: 25,
              maxLength: 75,
              borderRadius: BorderRadius.circular(8)),
        ),
        leading: const SkeletonAvatar(
          style: SkeletonAvatarStyle(
              shape: BoxShape.circle, width: 40, height: 40),
        ),
        subtitle: SkeletonLine(
          style: SkeletonLineStyle(
              height: 10,
              minLength: 25,
              maxLength: 75,
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _getNextPage({bool? reset}) async {
    _setIsSearching(true);
    if (reset != null) {
      _resetStudents();
      _resetPage();
      _resetGotAllUsers();
    }
    var userList = await _getUsers();
    _incrementPage();
    if (userList.length != perPage) {
      _setGotAllUsers();
    }
    setState(() {
      for (final item in userList) {
        final login = item['login'] as String? ?? '';
        final name = item['usual_full_name'] as String? ?? '';
        final avatarUrl = item['image_url'] as String? ?? '';
        final staff = item['staff?'] as bool? ?? false;
        final id = item['id'] as int? ?? 0;
        final user = StudentReduce(login, name, avatarUrl, staff, id);
        _users.add(user);
      }
    });
    _setIsSearching(false);

    await Future.delayed(const Duration(seconds: 1));
    _stopWaitingScroll();
    // print("page: " +
    //     (_page).toString() +
    //     " - total: " +
    //     _users.length.toString());
  }

  Future<List> _usersApiRequest(String url) async {
    String token = Provider.of<GlobalViewModel>(context, listen: false).token;
    List dataList = [];

    final responseUsers = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (responseUsers.statusCode != 200) {
      if (responseUsers.statusCode == 401) {
        getToken(context);
      }
      await Future.delayed(const Duration(seconds: 1));
      return _getUsers();
    } else {
      dataList = jsonDecode(responseUsers.body) as List;
    }
    return dataList;
  }

  Future<List> _getUsers() async {
    List loginList = [];
    List firstnameList = [];
    List lastnameList = [];

    loginList = await _usersApiRequest(
        'https://api.intra.42.fr/v2/users?filter[login]=$_name&per_page=$perPage&page=$_page');
    await Future.delayed(const Duration(milliseconds: 500));
    firstnameList = await _usersApiRequest(
        'https://api.intra.42.fr/v2/users?filter[first_name]=$_name&per_page=$perPage&page=$_page');
    await Future.delayed(const Duration(milliseconds: 500));
    lastnameList = await _usersApiRequest(
        'https://api.intra.42.fr/v2/users?filter[last_name]=$_name&per_page=$perPage&page=$_page');

    return [...loginList, ...firstnameList, ...lastnameList];
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500 &&
        !_waitResponseScroll &&
        !_gotAllUsers) {
      setState(() {
        _getNextPage();
        _startWaitingScroll();
      });
    }
  }
}
