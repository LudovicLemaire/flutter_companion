import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';

import 'get_token.dart';
import 'projects_view.dart';
import 'skills_view.dart';
import 'achievements_view.dart';
import 'expertises_view.dart';
import 'student.dart';
import 'main.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _UserView createState() => _UserView();
}

class _UserView extends State<UserView> {
  late Student _userData;
  bool _dataUserLoaded = false;
  Color _backgroundColor = const Color.fromARGB(255, 94, 94, 94);

  Future<void> _editUserData(Map<String, dynamic> newUserData,
      List<Map<String, dynamic>> skillsInfo) async {
    int cursusUsersId = 0;
    int currCursusUsersId = 0;
    List<DateTime> beginAtDates = [];
    for (var cursus in newUserData['cursus_users']) {
      cursus.forEach((k, v) => {
            if (k == 'end_at')
              {
                if (v == null)
                  cursusUsersId = currCursusUsersId
                else
                  beginAtDates.add(DateTime.parse(v.toString())),
              }
          });
      ++currCursusUsersId;
    }
    if (beginAtDates.length == newUserData['cursus_users'].length) {
      int dateId = 0;
      DateTime currDate = DateTime.parse('2000-01-01 00:00:00');
      for (var date in beginAtDates) {
        if (date.isAfter(currDate)) {
          currDate = date;
          cursusUsersId = dateId;
        }
        ++dateId;
      }
    }

    List<Map<String, dynamic>> finalProjects = [];
    List<dynamic> projects = newUserData['projects_users'];
    for (var project in projects) {
      Map<String, dynamic> formatProjects = project;
      if (!formatProjects['project']['slug'].startsWith('piscine-c')) {
        finalProjects.add(formatProjects);
      }
    }

    List<Map<String, dynamic>> allSkills = [];
    for (var skill in skillsInfo) {
      bool userHasKey = false;
      for (var userSkill
          in List.from(newUserData['cursus_users'][cursusUsersId]['skills'])) {
        if (userSkill['name'] == skill['name']) {
          allSkills.add({'name': skill['name'], 'level': userSkill['level']});
          userHasKey = true;
        }
      }
      if (!userHasKey) {
        allSkills.add({'name': skill['name'], 'level': 0});
      }
    }

    String location = newUserData['location'] as String? ?? '';
    location = location.split('.')[0];

    setState(() {
      _userData = Student(
          newUserData['login'] as String? ?? '',
          newUserData['displayname'] as String? ?? '',
          newUserData['image_url'] as String? ?? '',
          newUserData['staff?'] as bool? ?? false,
          newUserData['correction_point'] as int? ?? 0,
          newUserData['wallet'] as int? ?? 0,
          location,
          newUserData['cursus_users'][cursusUsersId]['grade'] as String? ?? '',
          newUserData['cursus_users'][cursusUsersId]['level'] as double? ?? 0,
          finalProjects,
          allSkills,
          List.from(newUserData['achievements']),
          List.from(newUserData['expertises_users']),
          newUserData['id'] as int? ?? 0);
    });
    return;
  }

  void _editDataUserLoaded() {
    setState(() {
      _dataUserLoaded = true;
    });
  }

  void _editBackgroundColor(Color newColor) {
    setState(() {
      _backgroundColor = newColor;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .editLoadingOverlay(true);
      Map<String, dynamic> userData = await _getUserInfo();
      List<Map<String, dynamic>> skillsInfo = await _getSkillsInfo();
      await _editUserData(userData, skillsInfo);
      _editDataUserLoaded();
      var palette = (await _getPalette(userData['image_url'])).dominantColor;
      if (palette != null) {
        _editBackgroundColor(palette.color);
      }
      Provider.of<GlobalViewModel>(context, listen: false)
          .editLoadingOverlay(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            _decorationPart(),
            _staffLocationPart(),
            _namesPart(),
            _commonInfoPart(),
            _levelPart(),
            _barSelectionPart(),
          ],
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          splashRadius: 20,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 35,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop);
  }

  Widget _decorationPart() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: _backgroundColor),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 35, 0, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 45, color: Colors.black, spreadRadius: 0)
              ],
            ),
            child: const CircleAvatar(
              radius: 95.0,
            ),
          ),
        ]),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 125, 0, 0),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(35),
                topLeft: Radius.circular(35),
              ),
              color: Color.fromARGB(255, 48, 48, 48)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_dataUserLoaded)
            Container(
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(_userData.avatarUrl),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                radius: 100,
              ),
            ),
          if (!_dataUserLoaded)
            Container(
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: const SkeletonAvatar(
                style: SkeletonAvatarStyle(
                    shape: BoxShape.circle, width: 200, height: 200),
              ),
            ),
        ])
      ],
    );
  }

  Widget _staffLocationPart() {
    return Stack(
      children: [
        if (_dataUserLoaded)
          Row(
            children: <Widget>[
              _activeLocationPart(),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                  child: const SizedBox.shrink(),
                ),
              ),
              _staffPart(),
            ],
          ),
      ],
    );
  }

  Widget _activeLocationPart() {
    return Expanded(
      flex: 3,
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 150, 0, 0),
          child: Column(
            children: [
              if (_userData.location.isNotEmpty)
                const Icon(
                  Icons.wifi,
                  color: Color.fromARGB(255, 45, 204, 113),
                  size: 30.0,
                )
              else
                const Icon(
                  Icons.wifi_off,
                  color: Color.fromARGB(255, 154, 45, 34),
                  size: 30.0,
                ),
              Text(
                _userData.location.isNotEmpty ? _userData.location : 'inactive',
                textAlign: TextAlign.center,
              )
            ],
          )),
    );
  }

  Widget _staffPart() {
    return Expanded(
      flex: 3,
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 150, 0, 0),
          child: Column(
            children: _userData.staff
                ? const [
                    Icon(
                      Icons.star,
                      color: Color.fromARGB(255, 242, 196, 16),
                      size: 30.0,
                    ),
                    Text(
                      'staff',
                      textAlign: TextAlign.center,
                    )
                  ]
                : [const SizedBox.shrink()],
          )),
    );
  }

  Widget _namesPart() {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 232, 0, 0),
        child: Center(
            child: Column(
          children: [
            if (_dataUserLoaded)
              Text(_userData.login,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            if (_dataUserLoaded)
              Text(_userData.name,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )));
  }

  Widget _commonInfoPart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 280, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Text(
                  'Wallet',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 10),
                ),
                const SizedBox(height: 2),
                if (_dataUserLoaded) Text('${_userData.wallet} ₳')
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Text(
                  'Grade',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 10),
                ),
                const SizedBox(height: 2),
                if (_dataUserLoaded) Text(_userData.grade)
              ],
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Text(
                  'Correction',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 10),
                ),
                const SizedBox(height: 2),
                if (_dataUserLoaded) Text(_userData.correctionPoints.toString())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelPart() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 325, 30, 0),
        child: Stack(
          children: <Widget>[
            if (!_dataUserLoaded)
              SizedBox(
                height: 20,
                child: LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: _backgroundColor,
                  color: Theme.of(context).primaryColor,
                  minHeight: 10,
                ),
              ),
            if (_dataUserLoaded)
              SizedBox(
                height: 20,
                child: LinearProgressIndicator(
                  value: (_userData.level / 21),
                  backgroundColor: _backgroundColor,
                  color: Theme.of(context).primaryColor,
                  minHeight: 10,
                ),
              ),
            if (_dataUserLoaded)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Align(
                  child: Text('Level ${_userData.level.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10)),
                  alignment: Alignment.topCenter,
                ),
              )
          ],
        ));
  }

  Widget _barSelectionPart() {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 355, 30, 0),
        child: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: TabBar(
                indicatorColor: Theme.of(context).secondaryHeaderColor,
                tabs: const [
                  Tab(icon: Icon(Icons.account_tree), text: "Projects"),
                  Tab(icon: Icon(Icons.bar_chart), text: "Skills"),
                  Tab(icon: Icon(Icons.emoji_events), text: "Achievements"),
                  Tab(icon: Icon(Icons.diamond), text: "Expertises"),
                ],
              ),
              body: TabBarView(
                children: [
                  _projectsPart(),
                  _skillsPart(),
                  _achievementsPart(),
                  _expertisesPart(),
                ],
              ),
            )));
  }

  Widget _projectsPart() {
    return _dataUserLoaded
        ? ProjectsView(
            projects: _userData.projects, dataUserLoaded: _dataUserLoaded)
        : const ProjectsView(projects: [], dataUserLoaded: false);
  }

  Widget _skillsPart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: _dataUserLoaded
          ? SkillsView(
              skills: _userData.skills,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _achievementsPart() {
    return _dataUserLoaded
        ? AchievementsView(
            achievements: _userData.achievements,
            dataUserLoaded: _dataUserLoaded)
        : const AchievementsView(achievements: [], dataUserLoaded: false);
  }

  Widget _expertisesPart() {
    return _dataUserLoaded
        ? ExpertisesView(
            expertises: _userData.expertises, dataUserLoaded: _dataUserLoaded)
        : const ExpertisesView(expertises: [], dataUserLoaded: false);
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    String token = Provider.of<GlobalViewModel>(context, listen: false).token;
    Map<String, dynamic> dataList = {};

    final responseUsers = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users/${widget.id.toString()}'),
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
      return _getUserInfo();
    } else {
      dataList = jsonDecode(responseUsers.body);
    }
    return dataList;
  }

  Future<List<Map<String, dynamic>>> _getSkillsInfo() async {
    String token = Provider.of<GlobalViewModel>(context, listen: false).token;
    List<Map<String, dynamic>> dataList = [];

    final responseUsers = await http
        .get(Uri.parse('https://api.intra.42.fr/v2/skills/'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (responseUsers.statusCode != 200) {
      if (responseUsers.statusCode == 401) {
        getToken(context);
      }
      await Future.delayed(const Duration(seconds: 1));
      return _getSkillsInfo();
    } else {
      dataList = List.from(jsonDecode(responseUsers.body));
    }
    return dataList;
  }

  Future<PaletteGenerator> _getPalette(String url) async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
    );
    await Future.delayed(const Duration(seconds: 1));

    return paletteGenerator;
  }
}
