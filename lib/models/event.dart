class Event {
  final String id;
  final String name;
  final String slug;
  final DateTime date;
  final String location;
  final String? bannerUrl;

  Event({
    required this.id,
    required this.name,
    required this.slug,
    required this.date,
    required this.location,
    this.bannerUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      bannerUrl: json['banner_url'] as String?,
    );
  }
}