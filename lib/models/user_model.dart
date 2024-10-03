class User {
  final int userId;
  final String userName;
  final String profilePicture;
  final List<Story> stories;

  User({
    required this.userId,
    required this.userName,
    required this.profilePicture,
    required this.stories,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Unknown',
      profilePicture: json['profile_picture'] ?? '',
      stories: (json['stories'] as List).map((story) => Story.fromJson(story)).toList(),
    );
  }
}

class Story {
  final int storyId;
  final String mediaUrl;
  final String mediaType;
  final String timestamp;
  final String text;
  final String textDescription;

  Story({
    required this.storyId,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
    required this.text,
    required this.textDescription,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      storyId: json['story_id'] ?? 0,
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image', // Default to 'image'
      timestamp: json['timestamp'] ?? '',
      text: json['text'] ?? '',
      textDescription: json['text_description'] ?? '',
    );
  }
}
