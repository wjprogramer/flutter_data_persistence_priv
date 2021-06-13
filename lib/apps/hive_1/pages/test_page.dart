import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Simple Test'),
      ),
      body: FutureBuilder<Box>(
        future: Hive.openBox('wjTestBox'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var text = '';
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              text = snapshot.error.toString();
            } else {
              var box = snapshot.data as Box;
              box.put('hi', 1);

              var hi = box.get('hi');
              text = hi.toString();
            }
          }

          return Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
