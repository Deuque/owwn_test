import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final Gender gender;
  final Status status;
  final List<int> statistics;

  const User({
    required this.id,
    required this.name,
    required this.gender,
    required this.status,
    required this.statistics,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      gender:
          Gender.values.firstWhere((element) => element.name == json['gender']),
      status:
          Status.values.firstWhere((element) => element.name == json['status']),
      statistics: List<int>.from((json['statistics'] ?? []) as List),
    );
  }

  String initials() {
    final names = name.split(' ');
    return names.take(2).map((e) => e.substring(0, 1).toUpperCase()).join();
  }

  String get email => '${initials()}@gmail.com';

  @override
  List<Object?> get props => [id, name, gender, status, statistics];
}

enum Gender { male, female, other }

enum Status { active, inactive }
