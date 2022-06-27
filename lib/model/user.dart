import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String initials;
  final Gender gender;
  final Status status;
  final List<int> statistics;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.gender,
    required this.status,
    required this.statistics,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final initials = name
        .split(' ')
        .take(2)
        .map(
          (e) => e.substring(0, 1).toUpperCase(),
        )
        .join();
    return User(
      id: json['id'] as String,
      name: name,
      email: '$initials@gmail.com',
      initials: initials,
      gender:
          Gender.values.firstWhere((element) => element.name == json['gender']),
      status:
          Status.values.firstWhere((element) => element.name == json['status']),
      statistics: List<int>.from((json['statistics'] ?? []) as List),
    );
  }

  @override
  List<Object?> get props => [id, name, email, gender, status, statistics];
}

enum Gender { male, female, other }

enum Status { active, inactive }
