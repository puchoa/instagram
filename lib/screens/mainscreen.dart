import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/friendpostscreen.dart';
import "package:instagram_clone/functions.dart";
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool liked;
  TextEditingController _textController;

 

 

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


  

  Widget buildTasks() {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    return ListView.builder(
      itemCount: bloc.timeline.length,
      itemBuilder: (context, i) {
        Post p = bloc.timeline[i];

        return _buildRow(p, i);
      },
    );
  }

  Widget _buildRow(Post p, int n) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    liked = p.liked;
    String profile_image = Functions.setimage(p.profile_image_url);
    String user_image = Functions.setimage(bloc.myAccount.profile_image_url);
  
    String com;

    var comment;


    if (p.comments_count > 0) {
      comment = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          // View All Comments
          FlatButton(
            child: Text("View all ${p.comments_count} comments",
                style: TextStyle(color: Colors.grey, fontSize: 14.0)),
            onPressed: () {
              setState(() {
                bloc.getcomment(p.id.toString());
              });

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendPostScreen(p: p, n: n),
                  ));
            },
          ),

          // Time ago for post
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 8.0, 8.0),
            child: Text(Functions.calTime(p),
                style: TextStyle(color: Colors.grey, fontSize: 14.0)),
          ),

          // Add comment to post
          FlatButton(
            child: Functions.addCommentImage(user_image), 
            onPressed: () {
              Functions.addCommentPopUp(context, _textController, com, n, bloc, p);
            },
          ),
        ],
      );
    } 
    else {
      comment = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          // Time since Post
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
            child: Text(Functions.calTime(p),
                style: TextStyle(color: Colors.grey, fontSize: 14.0)),
          ),

          // Add Comment
          FlatButton(
            child: Functions.addCommentImage(user_image),
            onPressed: () {
              Functions.addCommentPopUp(context, _textController, com, n, bloc, p);
            },
          ),
        ],
      );
    }

    if(p.user_id == bloc.myAccount.id){
      return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Functions.userImage_name(profile_image, p, p.user_id, context),
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
                                              Navigator.pop(context, 'Cancel');
                                              Navigator.pop(context, 'Cancel');
                                            },
                                          ),
                                          CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: new Text("Delete"),
                                              onPressed: () {

                                                _delPost(p.id.toString(), n);
                                                
                                                Navigator.pop(
                                                    context, 'Cancel');
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              }),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Functions.changeCaption(p.id.toString(), n, bloc, context),
                              
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

        
        
        // image
        Image.network(p.image_url),

        // Favorite
        IconButton(
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : Colors.black),
          highlightColor: Colors.white,
          onPressed: () {
            _pressed(p.id.toString(), p.liked, n);
          },
        ),

        // Likes
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 5),
          child: Text(p.likes_count.toString() + " likes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
        ),

        // Username + Captain
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 0),
          child: Functions.userName_Caption(p.username, p.caption),
        ),

        comment,

        Padding(
          padding: const EdgeInsets.only(bottom: 25),
        ),
      ],
    );

    }
    else{
      return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Functions.userImage_name(profile_image, p, p.user_id, context),


        // image
        Image.network(p.image_url),

        // Favorite
        IconButton(
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : Colors.black),
          highlightColor: Colors.white,
          onPressed: () {
            _pressed(p.id.toString(), p.liked, n);
          },
        ),

        // Likes
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 5),
          child: Text(p.likes_count.toString() + " likes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
        ),

        // Username + Captain
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 0),
          child: Functions.userName_Caption(p.username, p.caption),
        ),

        comment,

        Padding(
          padding: const EdgeInsets.only(bottom: 25),
        ),
      ],
    );
    }

    
  }

  @override
  Widget build(BuildContext context) {
    BottomBar.selectedIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Instagram",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: buildTasks(),
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
            icon: Icon(Icons.search, size: 30,color:  Colors.grey,),
            title: Text(''),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box, size: 30,color:  Colors.grey,), title: Text('')),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: 30,color:  Colors.grey,), title: Text('')),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, size: 30,color:  Colors.grey,), title: Text('')),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
