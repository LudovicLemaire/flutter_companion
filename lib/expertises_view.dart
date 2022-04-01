import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ExpertisesView extends StatefulWidget {
  const ExpertisesView(
      {Key? key, required this.expertises, required this.dataUserLoaded})
      : super(key: key);
  final List<Map<String, dynamic>> expertises;
  final bool dataUserLoaded;

  @override
  _ExpertisesView createState() => _ExpertisesView();
}

class _ExpertisesView extends State<ExpertisesView> {
  List<Map<String, dynamic>> _formatedExpertises = [];
  void _editFormatedData(List<Map<String, dynamic>> formatedExpertises) {
    setState(() {
      _formatedExpertises = formatedExpertises;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      List<Map<String, dynamic>> allExpertises = await getExpertisesJson();
      List<Map<String, dynamic>> formatedExpertises = [];
      for (var userExpertise in widget.expertises) {
        for (var expertise in allExpertises) {
          if (userExpertise['expertise_id'] == expertise['id']) {
            formatedExpertises.add({
              'name': expertise['name'],
              'kind': expertise['kind'],
              'level': userExpertise['value']
            });
          }
        }
      }
      _editFormatedData(formatedExpertises);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.dataUserLoaded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Material(
                child: ListView.separated(
                    itemCount: _formatedExpertises.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatedExpertises[index]['name']),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    flex: 4,
                                    child: Text(
                                        _formatedExpertises[index]['kind'],
                                        style: TextStyle(
                                            color: Colors.grey[500]))),
                                Flexible(
                                    flex: 6,
                                    child: IgnorePointer(
                                        child: RatingBar.builder(
                                      itemSize: 17,
                                      initialRating: _formatedExpertises[index]
                                              ['level']
                                          .toDouble(),
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onRatingUpdate: (rating) {},
                                    ))),
                              ],
                            ),
                          ],
                        ),
                      );
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

  Future<List<Map<String, dynamic>>> getExpertisesJson() async {
    final String response = kIsWeb
        ? await rootBundle.loadString('../assets/test.json')
        : await rootBundle.loadString('assets/test.json');
    final List<Map<String, dynamic>> dataList =
        List.from(await jsonDecode(response));
    return dataList;
  }
}
