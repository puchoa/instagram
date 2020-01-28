class Comment{

  int id;
  int user_id;
  int post_id;
  String text;
  DateTime created_at;

  Comment({this.id,
  this.user_id,
  this.post_id,
  this.text,
  this.created_at,
  });

  factory Comment.fromJson(Map<String, dynamic> json){
      return Comment(id: json["id"], 
      user_id: json["user_id"], 
      post_id: json["post_id"], 
      text: json["text"], 
      created_at: DateTime.parse(json["created_at"]), 
      );
    }



}