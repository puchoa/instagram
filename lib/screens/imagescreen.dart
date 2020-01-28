import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ImagePage extends StatefulWidget {
  File image;

  ImagePage({Key key, this.image}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  static final Text _upload =
      Text("Upload", style: TextStyle(color: Colors.black));
  static final Text _submitting =
      Text("Submitting", style: TextStyle(color: Colors.black));

  Widget loading() {
    return Container(
      color: Colors.white,
      height: 250.0,
      width: 300.0,
      child: CupertinoActivityIndicator(radius: 20),
    );
  }

  static Widget notLoading() {
    return Container();
  }

  
  

  Text _appbarText = _upload;
  Container animation = notLoading();
 

  @override
  Widget build(BuildContext mainContext) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    TextEditingController _textController;
    String b;

     
    


    return Scaffold(
        appBar: AppBar(
          title: _appbarText,
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
        body: Center(
            child: ListView(shrinkWrap: true, children: <Widget>[
          Stack(
            children: <Widget>[
             Image.file(widget.image),
              Positioned.fill(
                child: animation,
              )
            ],
          ),
          RaisedButton(
            
            child: Text("Upload"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => new CupertinoAlertDialog(
                  title: CupertinoTextField(
                    controller: _textController,
                    placeholder: 'Add a caption...',
                    placeholderStyle: const TextStyle(color: Colors.black),
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
                      },
                    ),
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: new Text("Submit"),
                        onPressed: () async {
                          Navigator.pop(context);

                          setState(() {

                            animation = animation == notLoading()
                                ? notLoading()
                                : loading();

                            _appbarText =
                                _appbarText == _upload ? _submitting : _upload;

                            
                          });

                          bool upload= await bloc.upload(widget.image, b);

                          if (upload == true) {
                            bool reload = await bloc.loadData(true);

                            if (reload == true) {
                              Navigator.push(
                                mainContext,
                                MaterialPageRoute(
                                    builder: (mainContext) => MainScreen()),
                              );
                            }
                          }
                        }),
                  ],
                ),
              );
            },
          )
        ])));
  }
}
