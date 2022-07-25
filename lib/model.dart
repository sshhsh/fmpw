class SiteModel {
  String site;
  String template;
  int count;
  SiteModel(this.site, this.template, this.count);
}

class UserSites {
  final String name;
  final Map<String, SiteModel> sites;
  UserSites(this.name, this.sites);

  UserSites.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        sites = json['sites'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'sites': sites,
      };
}
