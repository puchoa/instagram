import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:provider/provider.dart';
import "package:instagram_clone/functions.dart";

class FriendPostScreen extends StatefulWidget {
  Post p;
  int n;
  FriendPostScreen({
    Key key,
    this.p,
    this.n,
  }) : super(key: key);

  @override
  _FriendPostScreenState createState() => _FriendPostScreenState();
}

class _FriendPostScreenState extends State<FriendPostScreen> {
  int _selectedIndex = 0;
  bool liked = false;
  TextEditingController _textController;
  String userImage = "";
  List<Comment> comment = [];
  User u = new User(profile_image_url: "");

  _pressed(String i, bool like, int n) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    if (like == true) {
      bool del = await bloc.delLike(i, n, bloc);
      if (del == true) {
        like = false;
      }
    } else {
      bool add = await bloc.addLike(i, n, bloc);
      if (add == true) {
        like = true;
      }
    }
    setState(() {
      liked = like;
      widget.p.liked = like;
    });
  }

  void _onItemTapped(int index) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    List p = await bloc.getUserPost(bloc.myAccount.id.toString());
    List i = await bloc.getUserPosts(bloc.myAccount.id.toString());
    setState(() {
      _selectedIndex = index;
    });
    Functions.changeScreen(index, context, bloc, p, i);
  }

  _editCommentSubmit(Comment c, String com, int n) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    bool s = await bloc.editComment(c.id.toString(), com);

    if (s == true) {
      c.text = com;
      bloc.comments[n].text = c.text;
      Navigator.of(context).pop();
    }
  }

  _delComment(Comment c, int n, int i) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    bool s = await bloc.deleteComment(c.id.toString(), n, bloc);
    Post ss = bloc.timeline[n];

    if (s == true) {
      setState(() {
        --ss.comments_count;
        bloc.comments.removeAt(i);
      });
    }
  }

  _delPost(String id, int n) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    bool s = await bloc.deletePost(id, n, bloc);

    if (s == true) {
      setState(() {
        bloc.timeline.removeWhere((item) => item.id == int.parse(id));
        bloc.my_posts.removeWhere((item) => item.id == int.parse(id));

        bloc.notifyListeners();
      });
    }
  }

  List _buildList() {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    List<Widget> listItems = List();
    String profile_image = Functions.setimage(widget.p.profile_image_url);
    String user_image = Functions.setimage(bloc.myAccount.profile_image_url);
    String user_Name = "";

    if (widget.p.user_id == bloc.myAccount.id) {
      listItems.add(Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //User image and user name
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Functions.userImage_name(
                    profile_image, widget.p, widget.p.user_id, context),
                new Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoActionSheet(
                                    actions: <Widget>[
                                  CupertinoActionSheetAction(
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            new CupertinoAlertDialog(
                                          title: new Text("Delete Post?"),
                                          actions: [
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: new Text("Cancel"),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, 'Cancel');
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                            ),
                                            CupertinoDialogAction(
                                                isDefaultAction: true,
                                                child: new Text("Delete"),
                                                onPressed: () {
                                                  _delPost(
                                                      widget.p.id.toString(),
                                                      widget.n);

                                                  Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                anim1, anim2) =>
                                                            MainScreen(),
                                                        transitionsBuilder:
                                                            (context,
                                                                    anim1,
                                                                    anim2,
                                                                    child) =>
                                                                FadeTransition(
                                                                    opacity:
                                                                        anim1,
                                                                    child:
                                                                        child),
                                                        transitionDuration:
                                                            Duration(
                                                                seconds: 0),
                                                      ));
                                                }),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  Functions.changeCaption(widget.p.id.toString(), widget.n, bloc, context),
                                  
                                ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: const Text('Cancel'),
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    )),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Post image
            Image.network(widget.p.image_url),

            // Favorite
            IconButton(
              icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black),
              highlightColor: Colors.white,
              onPressed: () {
                _pressed(widget.p.id.toString(), widget.p.liked, widget.n);
              },
            ),

            // Likes
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 5),
              child: Text(widget.p.likes_count.toString() + " likes",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
            ),

            //User name and Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 0),
              child: Functions.userName_Caption(
                  widget.p.username, widget.p.caption),
            ),

            // Time since Post
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
              child: Text(Functions.calTime(widget.p),
                  style: TextStyle(color: Colors.grey, fontSize: 14.0)),
            ),
          ],
        ),
      ));
    } else {
      listItems.add(Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //User image and user name
            Functions.userImage_name(
                profile_image, widget.p, widget.p.user_id, context),

            // Post image
            Image.network(widget.p.image_url),

            // Favorite
            IconButton(
              icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black),
              highlightColor: Colors.white,
              onPressed: () {
                _pressed(widget.p.id.toString(), widget.p.liked, widget.n);
              },
            ),

            // Likes
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 5),
              child: Text(widget.p.likes_count.toString() + " likes",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
            ),

            //User name and Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 0),
              child: Functions.userName_Caption(
                  widget.p.username, widget.p.caption),
            ),

            // Time since Post
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
              child: Text(Functions.calTime(widget.p),
                  style: TextStyle(color: Colors.grey, fontSize: 14.0)),
            ),
          ],
        ),
      ));
    }

    for (int i = 0; i < bloc.comments.length; ++i) {
      for (int j = 0; j < bloc.timeline.length; ++j) {
        Post s = bloc.timeline[j];

        if (s.user_id == bloc.comments[i].user_id) {
          user_Name = s.username;
          break;
        }
      }

      String comment = bloc.comments[i].text;

      int userNum = bloc.comments[i].user_id;
      String image = "";

      if (comment == null) {
        comment = "";
      }

      if (bloc.comments[i].user_id == bloc.myAccount.id) {
        image = Functions.setimage(bloc.myAccount.profile_image_url);
      } else {
        for (int i = 0; i < bloc.timeline.length; ++i) {
          Post s = bloc.timeline[i];

          if (s.user_id == userNum) {
            image = Functions.setimage(s.profile_image_url);

            break;
          }
        }
      }

      listItems.add(
        // Button for user image and comment
        FlatButton(
          child: Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: new Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(image),
                            ),
                            border:
                                Border.all(color: Colors.grey, width: 0.3)))),

                Expanded(
                    child: RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              new TextSpan(
                                text: user_Name,
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold),
                              ),
                              new TextSpan(text: ' $comment')
                            ]))) //Text('$user_Name $comment'),)
              ],
            ),
          ),
          onPressed: () {
            // if user is not myAccount then goes to their account page
            if (bloc.comments[i].user_id != bloc.myAccount.id) {
              Functions.goPage(bloc.comments[i].user_id, context);
            } else {
              // Else user can edit and delete their comment
              String com;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // return object of type Dialog
                  return AlertDialog(
                    content: new TextFormField(
                      initialValue: bloc.comments[i].text,
                      autofocus: true,
                      controller: _textController,
                      onChanged: (i) {
                        com = i;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          print("cancel");
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Edit"),
                        onPressed: () {
                          print("Edit");
                          _editCommentSubmit(bloc.comments[i], com, i);
                        },
                      ),
                      FlatButton(
                        child:
                            Text("Delete", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _delComment(bloc.comments[i], widget.n, i);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      );
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    Post p = widget.p;
    liked = widget.p.liked;
    String com;

    String profile_image = Functions.setimage("${widget.p.profile_image_url}");
    String user_image = Functions.setimage(bloc.myAccount.profile_image_url);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                new TextSpan(
                    text: "${widget.p.username.toUpperCase()}",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.grey)),
                new TextSpan(
                    text: "\nPost",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0)),
              ]),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: <Widget>[
          new Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(delegate: new SliverChildListDelegate(_buildList())),
              ],
            ),
          ),
          new Row(
            children: <Widget>[
              FlatButton(
                child: Functions.addCommentImage(user_image),
                onPressed: () {
                  Functions.addCommentPopUp(
                      context, _textController, com, widget.n, bloc, p);
                },
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
              color: Colors.black,
            ),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
              color: Colors.grey,
            ),
            title: Text(''),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_box,
                size: 30,
                color: Colors.grey,
              ),
              title: Text('')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_border,
                size: 30,
                color: Colors.grey,
              ),
              title: Text('')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                size: 30,
                color: Colors.grey,
              ),
              title: Text('')),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
