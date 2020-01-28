import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/likescreen.dart';
import 'package:instagram_clone/screens/accountscreen.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _State createState() => _State();
}



class _State extends State<SearchScreen> {
 

     int _selectedIndex = 1;

static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  



   void _onItemTapped(int index) async {
      InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    List p = await bloc.getUserPost(bloc.myAccount.id.toString());
    List i = await bloc.getUserPosts(bloc.myAccount.id.toString());

    setState(() {
      _selectedIndex = index;
    });
     if(index == 4){
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
    else if(index == 3){
      Navigator.push(
        context, PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => LikeScreen(),
          transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
          transitionDuration: Duration(seconds: 0),));
    }
    else if (index == 0){
      Navigator.push(
        context, PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => MainScreen(),
          transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
          transitionDuration: Duration(seconds: 0),));

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:  Icon(Icons.home, size: 30),
            title:  Text(''),
          ),
             BottomNavigationBarItem(
           icon:  Icon(Icons.search, size: 30, color: Colors.black,),
           title:  Text(''),
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.add_box, size: 30),
           title: Text('')
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.favorite_border, size: 30),
           title: Text('')
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.account_circle, size: 30),
           title: Text('')
           
         ),
        ],
         onTap: _onItemTapped,
        
      ),

      
    );
  }
}