import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/postscreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import "package:instagram_clone/functions.dart";

class AccountScreen extends StatefulWidget {
  User u;
  int index;
  List pos;
  List images;
  AccountScreen({Key key, this.u, this.index, this.pos, this.images})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AccountScreen> {
  int _selectedIndex = 0;
  int numOfPost = 0;
  bool liked;
  bool pic;
  bool checker;
  TextEditingController _textController;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

 

  void _onItemTapped(int index) async {
   InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    List p = await bloc.getUserPost(bloc.myAccount.id.toString());
    List i = await bloc.getUserPosts(bloc.myAccount.id.toString());
    setState(() {
      _selectedIndex = index;
    });
    Functions.changeScreen(index, context, bloc, p, i);
  }

 

  Widget _setupGrid() {
    numOfPost = widget.pos.length;

    return new GridView.extent(
      maxCrossAxisExtent: 150.0,
      children: _buildTiles(numOfPost),
    );
  }

  List<Widget> _buildTiles(numOfPost) {
    List<Container> containers = new List<Container>.generate(numOfPost, (i) {
      Post image = widget.images[i];

      return new Container(
          child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: GestureDetector(
          onTap: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostScreen(
                        numPosition: i,
                        images: widget.images,
                        index: _selectedIndex,
                      )),);},
          child: new Container(
            child: new Image.network(
              image.image_url,
              fit: BoxFit.cover,),),),));});

    return containers;
  }

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    _selectedIndex = widget.index;

    String user_image = Functions.setimage(widget.u.profile_image_url);

    bool check = false;

    if(widget.u.id == bloc.myAccount.id){
      check = true;
    }

    String bio = widget.u.bio;
    if (bio == null) {
      bio = '';
    }
    String b;

    Icon home;

    
    

    
    Post im = widget.images[0];

    if(im.username != bloc.myAccount.email){
      return  Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.u.email}",
            style: TextStyle(color: Colors.black),
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
          actions: <Widget>[
            Functions.accountAction(check, context, bloc, _textController, bio, b),
           
          ],
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[

                // User profile image
                Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 8.0, 20.0),
                    child: new Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(user_image),
                          ),
                          border: Border.all(color: Colors.grey, width: 0.3)),
                    )),

                    // Posts , Followers, Following
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[

                          // Posts
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                40.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "${widget.images.length}",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nposts",
                                    ),
                                  ]),
                            ),
                          ),

                          // Followers
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "4.621",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nfollowers",
                                    ),
                                  ]),
                            ),
                          ),

                          // Following
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "709",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nfollowing",
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // User name and bio (Under profile image)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 50.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          new TextSpan(
                            text: "${widget.u.email}",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          new TextSpan(
                            text: "\n$bio",
                          ),
                        ]),
                  ),
                ),
              ],
            ),

            // Grid for user posts
            new Expanded(
              child: _setupGrid(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
              color:  Colors.black,
              size: 30),
              
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 30,
                color:  Colors.grey,
              ),
              title: Text(''),
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_box,
                  size: 30,
                  color:  Colors.grey,
                ),
                title: Text('')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border,
                  size: 30,
                  color:  Colors.grey,
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
    else{
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.u.email}",
            style: TextStyle(color: Colors.black),
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
          actions: <Widget>[
            Functions.accountAction(check, context, bloc, _textController, bio, b),
           
          ],
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[

                // User profile image
                Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 8.0, 20.0),
                    child: new Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(user_image),
                          ),
                          border: Border.all(color: Colors.grey, width: 0.3)),
                    )),

                    // Posts, Followers, Following
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[

                          // Posts
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                40.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "${widget.images.length}",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nposts",
                                    ),
                                  ]),
                            ),
                          ),

                          // Followers
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "4.621",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nfollowers",
                                    ),
                                  ]),
                            ),
                          ),

                          // Following
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 50.0, 8.0, 50.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: "709",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(
                                      text: "\nfollowing",
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // User name and bio (Under profile image)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 50.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          new TextSpan(
                            text: "${widget.u.email}",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          new TextSpan(
                            text: "\n$bio",
                          ),
                        ]),
                  ),
                ),
              ],
            ),

            // Grid user posts
            new Expanded(
              child: _setupGrid(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
              color:  Colors.grey,
              size: 30),
              
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 30,
                color:  Colors.grey,
              ),
              title: Text(''),
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_box,
                  size: 30,
                  color:  Colors.grey,
                ),
                title: Text('')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border,
                  size: 30,
                  color:  Colors.grey,
                ),
                title: Text('')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.account_circle,
                  size: 30,
                  color:  Colors.black 
                ),
                title: Text('')),
          ],
          onTap: _onItemTapped,
        ),
      );
    } 
  }
}
