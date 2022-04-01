import 'radar_chart.dart';
import 'package:flutter/material.dart';

class SkillsView extends StatelessWidget {
  const SkillsView({Key? key, required this.skills}) : super(key: key);
  final List<Map<String, dynamic>> skills;

  @override
  Widget build(BuildContext context) {
    List<num> data = [];
    List<String> features = [];
    for (var skill in skills) {
      skill.forEach((k, v) => {
            if (k == 'level')
              {
                data.add(v + 1),
              },
            if (k == 'name') features.add(v),
          });
    }

    List<int> ticks = [7, 14, 21];

    return RadarChart.dark(
      ticks: ticks,
      features: features,
      data: [data],
      useSides: true,
    );
  }
}
