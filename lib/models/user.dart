class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
    );
  }
}
