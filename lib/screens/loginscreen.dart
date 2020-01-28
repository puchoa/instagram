import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 50),
                child: Text("Instagram",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 30))),
            Container(
              width: 350,
              height: 250,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: usernameCtrl,
                        decoration: InputDecoration(hintText: "Email"),
                      ),
                      TextField(
                        controller: passwordCtrl,
                        decoration: InputDecoration(hintText: "Password"),
                        obscureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: RaisedButton(
                          child: Text("Login"),
                          onPressed: () async {
                            //fetch token
                            bloc.attemptLogin(usernameCtrl.text, passwordCtrl.text);
                            

                           
                          },
                        ),
                      ),
                      Text(
                        bloc.didLoginFail ? "Login failed" : "",
                        style: TextStyle(color: Colors.redAccent),
                      )
                    ],
                  ),
                )),
              ),
            ),
          ],
        )));
  }
}
