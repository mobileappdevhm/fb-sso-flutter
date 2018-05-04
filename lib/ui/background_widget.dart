import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BackgroundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
        decoration: new BoxDecoration(image: new DecorationImage(image: new AssetImage("res/bg.jpg"), fit: BoxFit.cover)),
        child: new BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: new Container(
            decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
          ),
        ));
  }
}
