class UserProfile {
  String name;
  String? email;
  String? studyRoutine;
  String? specificNeeds;

  UserProfile({
    this.name = '',
    this.email,
    this.studyRoutine,
    this.specificNeeds,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'studyRoutine': studyRoutine,
        'specificNeeds': specificNeeds,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        email: json['email'],
        studyRoutine: json['studyRoutine'],
        specificNeeds: json['specificNeeds'],
      );
}
