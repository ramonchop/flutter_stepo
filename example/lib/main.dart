import 'package:flutter/material.dart';
import 'package:stepo/stepo.dart';

void main() => runApp(StepoApp());

class StepoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stepo(
            key: UniqueKey(),
            orientation: StepoOrientation.vertical,
            textColor: Colors.black54,
            iconColor: Colors.black54,
            initialCounter: 1,
            lowerBound: 1,
          ),
        ],
      )),
    );
  }
}
