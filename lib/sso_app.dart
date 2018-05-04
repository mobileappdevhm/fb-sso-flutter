import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sso/sso/access_token.dart';
import 'package:sso/sso/facebook_sso.dart';
import 'package:sso/ui/background_widget.dart';
import 'package:http/http.dart' as http;

class SSOApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: "SSO Application", home: new SSOPage());
  }
}

class SSOPage extends StatelessWidget {
  /*
  PROVIDE YOUR APP CREDENTIALS
   */
  static const String APP_ID = "";
  static const String APP_SECRET = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(children: <Widget>[
      new BackgroundWidget(),
      new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new ClipRect(
                child: new Stack(
              children: [
                new Positioned(
                    // ignore: conflicting_dart_import
                    child: new Text("SSO with Facebook", style: new TextStyle(color: Colors.black, fontWeight: FontWeight.w100), textScaleFactor: 3.0)),
                new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: new Text("SSO with Facebook", style: new TextStyle(color: Colors.white, fontWeight: FontWeight.w100), textScaleFactor: 3.0)),
              ],
            )),
            new Padding(padding: new EdgeInsets.all(20.0)),
            new RaisedButton(
                onPressed: () {
                  _loginWithFacebook(context);
                },
                color: Colors.white,
                child: new Text("Sign in", textScaleFactor: 2.0, style: new TextStyle(fontWeight: FontWeight.w300)),
                padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.all(new Radius.circular(10000.0))))
          ],
        ),
      ),
    ], fit: StackFit.expand));
  }

  void _loginWithFacebook(BuildContext context) async {
    FacebookSSO sso = new FacebookSSO(applicationID: APP_ID, applicationSecret: APP_SECRET);

    String authorizationCode = await sso.authorize();
    AccessToken accessToken = await sso.accessToken(authorizationCode);

    // Fetch some data from the Facebook Graph API!
    http.Response response = await http.get("https://graph.facebook.com/me?access_token=${accessToken.accessToken}");

    Map<String, dynamic> userData = json.decode(response.body);

    String name = userData["name"];
    int id = int.tryParse(userData["id"]) ?? -1;

    Navigator.push(context, new MaterialPageRoute(builder: (context) => new ProfilePage(name, "https://graph.facebook.com/$id/picture?height=200")));
  }
}

class ProfilePage extends StatelessWidget {
  final String name;
  final String pictureUrl;

  ProfilePage(this.name, this.pictureUrl);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(children: <Widget>[
      new BackgroundWidget(),
      new Center(
        child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          new Container(
            width: 200.0,
            height: 200.0,
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new NetworkImage(pictureUrl), fit: BoxFit.cover),
              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              border: new Border.all(
                color: Colors.white,
                width: 5.0,
              ),
            ),
          ),
          new Padding(padding: new EdgeInsets.all(20.0)),
          new ClipRect(
            child: new Stack(
              children: [
                new Positioned(child: new Text(name, style: new TextStyle(color: Colors.black, fontWeight: FontWeight.w300), textScaleFactor: 3.0)),
                new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: new Text(name, style: new TextStyle(color: Colors.white, fontWeight: FontWeight.w300), textScaleFactor: 3.0)),
              ],
            ),
          ),
        ]),
      )
    ]));
  }
}
