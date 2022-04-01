class StudentReduce {
  final String login;
  final String avatarUrl;
  final String name;
  final bool staff;
  final int id;
  StudentReduce(this.login, this.name, this.avatarUrl, this.staff, this.id);
}

class Student {
  final String login;
  final String avatarUrl;
  final String name;
  final bool staff;
  final int correctionPoints;
  final int wallet;
  final String location;
  final String grade;
  final double level;
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> skills;
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> expertises;
  final int id;
  Student(
      this.login,
      this.name,
      this.avatarUrl,
      this.staff,
      this.correctionPoints,
      this.wallet,
      this.location,
      this.grade,
      this.level,
      this.projects,
      this.skills,
      this.achievements,
      this.expertises,
      this.id);
}
