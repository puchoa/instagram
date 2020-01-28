import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/accountscreen.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/likescreen.dart';
import 'package:instagram_clone/screens/loginscreen.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/screens/imagescreen.dart';
import 'package:instagram_clone/screens/searchscreen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class Functions {
  static String setimage(String image) {
    if (image == null) {
      return "https://t4.ftcdn.net/jpg/00/64/67/27/240_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg";
    }
    return image;
  }

  static String calTime(Post p) {
    var timeNow = DateTime.now();
    var postTime = p.created_at;
    var time = timeNow.difference(postTime).inDays;

    String calTime = "";

    if (time > 0) {
      if (time == 1) {
        calTime = "$time day ago";
      } else {
        calTime = "$time days ago";
      }
    } else {
      time = timeNow.difference(postTime).inHours;
      if (time > 0) {
        if (time == 1) {
          calTime = "$time hour ago";
        } else {
          calTime = "$time hours ago";
        }
      } else {
        time = timeNow.difference(postTime).inMinutes;
        if (time > 0) {
          if (time == 1) {
            calTime = "$time minute ago";
          } else {
            calTime = "$time minutes ago";
          }
        } else {
          time = timeNow.difference(postTime).inSeconds;
          if (time > 0) {
            if (time == 1) {
              calTime = "$time second ago";
            } else {
              calTime = "$time seconds ago";
            }
          } else {
            calTime = "1 second ago";
          }
        }
      }
    }

    return calTime;
  }

  static goPage(int id, BuildContext context) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    List p = await bloc.getUserPost(id.toString());
    List i = await bloc.getUserPosts(id.toString());
    List iCopy = i.reversed.toList();
    User f = await bloc.fetchUserAccount(id.toString());

    int number;
    if (id == bloc.myAccount.id) {
      number = 4;
    } else {
      number = 0;
    }

    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => AccountScreen(
            u: f,
            index: number,
            pos: p,
            images: iCopy,
          ),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
          transitionDuration: Duration(seconds: 0),
        ));
  }

  static FlatButton userImage_name(
      String profile_image, Post p, int id, BuildContext context) {
    return FlatButton(
      child: new Row(
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
                        image: new NetworkImage(profile_image),
                      ),
                      border: Border.all(color: Colors.grey, width: 0.3)))),
          Text(p.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0))
        ],
      ),
      onPressed: () {
        goPage(id, context);
      },
    );
  }

  static RichText userName_Caption(String username, String caption) {
    return RichText(
      textAlign: TextAlign.left,
      text: new TextSpan(style: TextStyle(color: Colors.black), children: <
          TextSpan>[
        new TextSpan(
            text: username,
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
        new TextSpan(text: " " + caption, style: new TextStyle(fontSize: 14.0)),
      ]),
    );
  }

  static Widget addCommentImage(String user_image) {
    return new Row(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
            child: new Container(
                width: 25.0,
                height: 25.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(user_image),
                    ),
                    border: Border.all(color: Colors.grey, width: 0.3)))),
        Text("Add a comment...",
            style: TextStyle(color: Colors.grey, fontSize: 14.0))
      ],
    );
  }

  static addComment(String com, int n, InstagramBloc bloc, Post p) async {
    if (com != null || com != 'null') {
      bool add = await bloc.addComment(p.id.toString(), com, n, bloc);
      if (add == true) {
        print("submit");
      }
    }
  }

  static addCommentPopUp(
      BuildContext context,
      TextEditingController _textController,
      String com,
      int n,
      InstagramBloc bloc,
      Post p) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new TextField(
            autofocus: true,
            decoration: new InputDecoration(
              hintText: "Add a comment",
            ),
            controller: _textController,
            onChanged: (i) {
              com = i;
            },
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Submit"),
              onPressed: () {
                addComment(com, n, bloc, p);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Widget changeCaption(String id, int n, InstagramBloc bloc, BuildContext context){
    TextEditingController _textController;
    String caption ="";

    Post s = bloc.timeline[n];

    _textController = new TextEditingController();
    _textController.value = TextEditingValue(text: s.caption);

      return CupertinoActionSheetAction(
                                  child: const Text('Edit'),
                                  onPressed: () {
                                   
                                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          new CupertinoAlertDialog(
                        title: CupertinoTextField(
                          controller: _textController,
                          placeholder: 'Tell us about yourself post',
                          placeholderStyle:
                              const TextStyle(color: Colors.black),
                          onChanged: (i) {
                            caption = i;
                          },
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              child: new Text("Submit"),
                              onPressed: () async {
                                if (caption != null) {
                                  bool update = await bloc.updatePostCaption(id, caption, n, bloc);

                                  if (update == true){
                                    
                                    
                                    Navigator.pop(context);
                                  Navigator.pop(context);

                                  }
                                  
                                }
                              }),
                        ],
                      ),
                    );
                                  },
                                );

    


  }

  static changeScreen(
      int index, BuildContext context, InstagramBloc bloc, List p, List i) async{
    if (index == 4) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => AccountScreen(
              u: bloc.myAccount,
              index: 4,
              pos: p,
              images: i,
            ),
            transitionsBuilder: (context, anim1, anim2, child) =>
                FadeTransition(opacity: anim1, child: child),
            transitionDuration: Duration(seconds: 0),
          ));
    }
    else if(index == 2){
      File _image;
      _image = await ImagePicker.pickImage(source: ImageSource.gallery);
      //_image = await ImagePicker.pickImage(source: ImageSource.camera);

      if (_image != null){
         Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => ImagePage(image: _image,),
          ));

      }
    }
    
     else if (index == 3) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => LikeScreen(),
            transitionsBuilder: (context, anim1, anim2, child) =>
                FadeTransition(opacity: anim1, child: child),
            transitionDuration: Duration(seconds: 0),
          ));
    } else if (index == 1) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => SearchScreen(),
            transitionsBuilder: (context, anim1, anim2, child) =>
                FadeTransition(opacity: anim1, child: child),
            transitionDuration: Duration(seconds: 0),
          ));
    } else if (index == 0) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => MainScreen(),
            transitionsBuilder: (context, anim1, anim2, child) =>
                FadeTransition(opacity: anim1, child: child),
            transitionDuration: Duration(seconds: 0),
          ));
    }
  }

  static Widget accountAction(
      bool check,
      BuildContext context,
      InstagramBloc bloc,
      TextEditingController _textController,
      String bio,
      String b) {
    if (check == false) {
      return Text("");
    }
    

    // Set controller to have bio text
    _textController = new TextEditingController();
    _textController.value = TextEditingValue(text: bio);

    return IconButton(
      icon: Icon(
        Icons.dehaze,
        color: Colors.black,
      ),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: const Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          new CupertinoAlertDialog(
                        title: new Text("Are you sure?"),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                              Navigator.pop(context, 'Cancel');
                            },
                          ),
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              child: new Text("Sign Out"),
                              onPressed: () async {
                                bloc.logout();
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, anim1, anim2) =>
                                       LoginScreen(),
                                      
                                    ));
                              }),
                        ],
                      ),
                    );
                  },
                ),
                CupertinoActionSheetAction(
                  child: const Text(
                    'Edit Bio',
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          new CupertinoAlertDialog(
                        title: CupertinoTextField(
                          controller: _textController,
                          placeholder: 'Tell us about yourself :D',
                          placeholderStyle:
                              const TextStyle(color: Colors.black),
                          onChanged: (i) {
                            b = i;
                          },
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              child: new Text("Submit"),
                              onPressed: () async {
                                if (b != null) {
                                  await bloc.updateBio(b, bloc);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }),
                        ],
                      ),
                    );
                  },
                ),
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
    );
  }
}

class BottomBar extends Functions {
  static int selectedIndex;
  static BuildContext context;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Search',
      style: optionStyle,
    ),
    Text(
      'Index 2: Add Photo',
      style: optionStyle,
    ),
    Text(
      'Index 3: Likes',
      style: optionStyle,
    ),
    Text(
      'Index 4: Profile',
      style: optionStyle,
    )
  ];

  static void onItemTapped(int index) {
    selectedIndex = index;
  }
}
