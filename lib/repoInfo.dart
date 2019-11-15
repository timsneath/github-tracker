// Metadata for an individual repository
class RepoInfo {
  final String repoName;
  final int stars;
  final int openIssues;
  final bool isArchived;

  RepoInfo({this.repoName, this.stars, this.openIssues, this.isArchived});

  RepoInfo.fromJson(Map<String, dynamic> json)
      : repoName = json['full_name'],
        stars = json['stargazers_count'],
        openIssues = json['open_issues_count'],
        isArchived = json['archived'];

  Map<String, dynamic> toJson() => {
        'full_name': repoName,
        'stargazers_count': stars,
        'open_issues_count': openIssues,
        'archived': isArchived
      };

  @override
  String toString() =>
      "Repo: $repoName | Stars: $stars | openIssues: $openIssues | isArchived: $isArchived";
}
