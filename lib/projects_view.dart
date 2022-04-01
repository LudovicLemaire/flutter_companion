import 'package:flutter/material.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView(
      {Key? key, required this.projects, required this.dataUserLoaded})
      : super(key: key);
  final List<Map<String, dynamic>> projects;
  final bool dataUserLoaded;

  @override
  Widget build(BuildContext context) {
    return dataUserLoaded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Material(
                child: ListView.separated(
                    itemCount: projects.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _itemList(position);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    })),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: ListView.separated(
                shrinkWrap: true,
                itemCount: 7,
                itemBuilder: (BuildContext context, int position) {
                  return ListTile(
                    title: const Text(''),
                    subtitle: const Text(''),
                    tileColor: position % 3 == 0
                        ? const Color(0x3Ef2c410)
                        : const Color(0x3E2DCC71),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                }),
          );
  }

  Widget _itemList(int i) {
    return ListTile(
      title: Text(
        projects[i]['project']['slug'],
      ),
      subtitle: Text(projects[i]['status']),
      trailing: (projects[i]['validated?'] != null)
          ? Text(
              projects[i]['final_mark'].toString(),
              style: const TextStyle(fontSize: 15),
            )
          : const SizedBox.shrink(),
      tileColor: _getColorProjectList(i),
    );
  }

  Color _getColorProjectList(int i) {
    switch (projects[i]['status']) {
      case 'finished':
        if (projects[i]['validated?'] == false) {
          return const Color(0x3Ee74d3d);
        } else {
          return const Color(0x3E2DCC71);
        }
      case 'in_progress':
        return const Color(0x3Ef2c410);
      case 'searching_a_group':
        return const Color(0x3Ef2c410);
      case 'creating_group':
        return const Color(0x3Ef2c410);
      default:
        return const Color(0x3Ee74d3d);
    }
  }
}
