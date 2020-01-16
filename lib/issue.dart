class Issue {
  final int number;
  final String title;
  final Status status;
  final DateTime created;
  final DateTime lastUpdated;
  final Uri htmlUrl;

  Issue(
      {this.number,
      this.title,
      this.status,
      this.created,
      this.lastUpdated,
      this.htmlUrl});

  Issue.fromJson(Map<String, dynamic> json)
      : number = int.parse(json['number']),
        title = json['title'],
        status = json['state'] == 'open'
            ? Status.open
            : json['state'] == 'closed' ? Status.closed : Status.unknown,
        created = DateTime.parse(json['created_at']),
        lastUpdated = DateTime.parse(json['updated_at']),
        htmlUrl = Uri.parse(json['html_url']);

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'status': status == Status.open
            ? 'open'
            : status == Status.closed ? 'closed' : 'unknown',
        'created_at': created.toIso8601String(),
        'updated_at': lastUpdated.toIso8601String(),
        'html_url': htmlUrl.toString()
      };

  @override
  String toString() => "#$number: $title";
}

enum Status { open, closed, unknown }
