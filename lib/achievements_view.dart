import 'package:skeletons/skeletons.dart';
import 'package:flutter/material.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView(
      {Key? key, required this.achievements, required this.dataUserLoaded})
      : super(key: key);
  final List<Map<String, dynamic>> achievements;
  final bool dataUserLoaded;

  @override
  Widget build(BuildContext context) {
    return dataUserLoaded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Material(
                child: ListView.separated(
                    itemCount: achievements.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _itemList(context, position);
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
                    title: SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 10,
                          minLength: 25,
                          maxLength: MediaQuery.of(context).size.width - 50,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    subtitle: SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 10,
                          minLength: 35,
                          maxLength: MediaQuery.of(context).size.width - 50,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                }),
          );
  }

  Widget _itemList(BuildContext context, int i) {
    return ListTile(
        title: Text(
          achievements[i]['name'],
        ),
        subtitle: Text(achievements[i]['description']),
        leading: Icon(
          (i % 5) == 0
              ? Icons.school
              : (i % 4) == 0
                  ? Icons.star
                  : (i % 3) == 0
                      ? Icons.favorite
                      : (i % 2) == 0
                          ? Icons.memory
                          : Icons.settings_suggest,
          color: Colors.grey,
          size: 40.0,
        ));
  }
}
