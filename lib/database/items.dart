class Item {
  int id;
  String name;
  Map<String, String> socialMedia;
  String member;
  String pic;
  String events;
  String tell;
  String status;
  String editor;

  Item(this.id, this.name, this.socialMedia, this.member, this.pic, this.events,
      this.tell, this.status, this.editor);

  factory Item.fromJson(Map<String, dynamic> map) {
    return Item(map["id"], map["name"], map["socialMedia"], map["member"],
        map["editor"], map["status"], map["pic"], map["events"], map["tell"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "socialMedia": socialMedia,
      "member": member,
      "pic": pic,
      "events": events,
      "tell": tell,
      "status": status,
      "editor": editor
    };
  }
}
