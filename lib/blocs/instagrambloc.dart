import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:instagram_clone/models/user.dart';
import 'package:dio/dio.dart';


class InstagramBloc extends ChangeNotifier {
  bool isReady = false;
   bool isUploadReady = false;
  bool isLoggedIn = false;
  bool didLoginFail = false;
  bool didLoadFail = false;
  List<Post> timeline = [];
  List<Post> my_posts = [];
  List<Comment> comments = [];
  List<User> users = [];
  User myAccount;
  User friendAccount;
  static String token;

  InstagramBloc() {
    setup();
  }

  Future<void> setup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = (prefs.getString('token') ?? null);
    if (token != null) {
      isLoggedIn = true;
      notifyListeners();
      loadData(false);
    }
  }

  Future<bool> loadData(bool check) async {
    if (isLoggedIn) {
      bool fetchedTimeline = await fetchTimeline();
      bool fetchedAccount = await fetchAccount();
      if (fetchedTimeline && fetchedAccount) {
        print("is ready");
        isReady = true;
        if(check == true){
          isUploadReady = true;
        }
        notifyListeners();
        return true;
      } else {
        print("is not ready");
        didLoadFail = true;
        notifyListeners();
        return false;
      }
    } else {
      print("not logged in");
      return false;
    }
  }

  Future<void> attemptLogin(String username, String password) async {
    print(
        "attempting login https://nameless-escarpment-45560.herokuapp.com/api/login?username=${username}&password=${password}");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/login?username=${username}&password=${password}");
    if (response.statusCode == 200) {
      print("succeeded login");
      didLoginFail = false;
      Map<String, dynamic> jsonData = json.decode(response.body);
      token = jsonData["token"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      if (token != null) {
        isLoggedIn = true;
      }
      notifyListeners();
    } else {
      print(response.body);
      print("login did not succeed");
      didLoginFail = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    isLoggedIn = false;
    notifyListeners();
    print('Logged out');
  }

  Future<bool> fetchTimeline() async {
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      List<dynamic> serverPosts = json.decode(response.body);
      for (int i = serverPosts.length - 1; i >= 0; i--) {
        timeline.add(Post.fromJson(serverPosts[i]));
      }
      return true;
    }
    return false;
  }

  Future<bool> fetchAccount() async {
    print("getting account data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/my_account",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      myAccount = User.fromJson(json.decode(response.body));

      print("getting account posts");
      var my_posts_response = await http.get(
          "https://nameless-escarpment-45560.herokuapp.com/api/v1/my_posts",
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      if (my_posts_response.statusCode == 200) {
        print("successfully got account posts");
        List<dynamic> server_posts = json.decode(my_posts_response.body);

        for (int i = server_posts.length - 1; i >= 0; i--) {
          my_posts.add(Post.fromJson(server_posts[i]));
        }
        //my_posts = server_posts.map((p) => Post.fromJson(p)).toList();
        return true;
      }
    } else {
      print(response.body);
      print("account load failed");
    }
    return false;
  }

  Future<User> fetchUserAccount(String id) async {
    print("getting friend account data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$id",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      print("Got friend account data");
      friendAccount = User.fromJson(json.decode(response.body));

      return friendAccount;
    } else {
      print(response.body);
      print("account load failed");
    }
    return null;
  }

  Future<List> getUserPosts(String id) async {
    print("getting friend posts data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$id/posts",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      print("Got friend account data");
      List<dynamic> server_posts = json.decode(response.body);
      List<Post> p = [];

      for (int i = 0; i < server_posts.length; ++i) {
        p.add(Post.fromJson(server_posts[i]));
      }

      notifyListeners();

      return p;
    } else {
      print(response.body);
      print("account load failed");
    }
    return null;
  }

  Future<bool> updateBio(String bio, InstagramBloc bloc) async {
    print("getting BIO data");
    var response = await http.patch(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/my_account?bio=$bio",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    print(response.statusCode);
    if (response.statusCode == 200) {
      bloc.myAccount.bio = bio;
      notifyListeners();

      print("BIO updated");

      return true;
    }
    print("Failed to update bio");
    return false;
  }

  Future<bool> delLike(String i, int n, InstagramBloc bloc) async {
    print("getting LIKE data");
    var response = await http.delete(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$i/likes",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      Post p = bloc.timeline[n];
      p.liked = false;
      --p.likes_count;
      notifyListeners();
      print("LIKE deleted");

      return true;
    } else {
      print(response.body);
      print("Failed to delete LIKE");
    }
    return false;
  }

  Future<bool> addLike(String i, int n, InstagramBloc bloc) async {
    print("getting LIKE data");
    var response = await http.post(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$i/likes",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 201) {
      Post p = bloc.timeline[n];
      p.liked = true;
      ++p.likes_count;
      notifyListeners();

      print("LIKE added");

      return true;
    } else {
      print(response.body);
      print("Failed to add LIKE");
    }
    return false;
  }

  Future<bool> addComment(
      String i, String comment, int n, InstagramBloc bloc) async {
    print("getting Comment data");
    var response = await http.post(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$i/comments?text=$comment",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      Post p = bloc.timeline[n];
      ++p.comments_count;
      notifyListeners();

      print("COMMENT added");
      getcomment(i);

      return true;
    } else {
      print(response.body);
      print("Failed to add COMMENT");
    }
    return false;
  }

  Future<List> getUserPost(String id) async {
    print("getting User data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$id/posts",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      List<dynamic> server_posts = json.decode(response.body);

      print("Got user posts");
      notifyListeners();

      return server_posts;
    } else {
      print(response.body);
      print("Failed to get user posts");
    }
    return null;
  }

  Future<bool> getUserAccount(String id) async {
    print("getting friend account data");

    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$id",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      print("Got friend account data");
      friendAccount = User.fromJson(json.decode(response.body));
    }
  }

  Future<bool> getcomment(String id) async {
    print("getting post comment data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$id/comments",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      comments.clear();
      users.clear();
      List<dynamic> server_posts = json.decode(response.body);

      for (int i = 0; i < server_posts.length; ++i) {
        comments.add(Comment.fromJson(server_posts[i]));
      }
      notifyListeners();
      return true;
    } else {
      print(response.body);
      print("Failed to get post comment");
    }
    return false;
  }

  Future<bool> editComment(String id, String comment) async {
    print("getting comment data");
    var response = await http.patch(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/comments/$id?text=$comment",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      print("Editted comment");

      return true;
    } else {
      print(response.body);
      print("Failed to edit comment");
    }
    return false;
  }

  Future<bool> deleteComment(String id, int n, InstagramBloc bloc) async {
    print("getting comment data");
    var response = await http.delete(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/comments/$id",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 204) {
      print("Comment deleted");

      return true;
    } else {
      print(response.body);
      print("Failed to delete comment");
    }
    return false;
  }

  Future<bool> deletePost(String id, int n, InstagramBloc bloc) async {
    print("getting Post data");
    var response = await http.delete(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$id",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 202) {
      print("Post deleted");

      return true;
    } else {
      print(response.body);
      print("Failed to delete Post");
    }
    return false;
  }

  Future<bool> updatePostCaption(
      String id, String caption, int n, InstagramBloc bloc) async {
    print("getting Post data");
    var response = await http.patch(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$id?caption=$caption",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      Post t = bloc.timeline[n];

      for (int i = 0; i < bloc.my_posts.length; ++i) {
        Post s = bloc.my_posts[i];
        if (s.id == t.id) {
          s.caption = caption;
        }
      }
      t.caption = caption;
      bloc.notifyListeners();

      print("Post caption updated");

      return true;
    } else {
      print(response.body);
      print("Failed to update Post caption");
    }
    return false;
  }

  Future<bool> upload(File _image, String caption) async {
    var response;

    print("Getting ready to upload");
    FormData formData = new FormData.from(
        {"caption": caption, "image": new UploadFileInfo(_image, _image.path)});
     response = await Dio().post(
      "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts",
      data: formData,
      options: Options(
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      ),
    );

    if (response.statusCode == 200) {
      print("Upload was successful");
      Map<String, dynamic> u = jsonDecode(response.toString()); 
      Post s = Post.fromJson(u);
      timeline.clear();
      my_posts.clear();
      isUploadReady = false;
      
      notifyListeners();
     

    
    

      return true;
    }
    print("Upload failed");
    print(response);
    return false;
  }
}
