class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? deviceToken;
  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.deviceToken,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    deviceToken = json['deviceToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    data['deviceToken'] = deviceToken;
    return data;
  }
}
