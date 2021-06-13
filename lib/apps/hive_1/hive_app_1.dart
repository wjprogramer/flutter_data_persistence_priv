import 'package:flutter/material.dart';
import 'package:flutter_data_persistence_priv/apps/hive_1/pages/contact_page.dart';
import 'package:hive/hive.dart';

class HiveApp1 extends StatefulWidget {
  const HiveApp1({Key? key}) : super(key: key);

  @override
  _HiveApp1State createState() => _HiveApp1State();
}

class _HiveApp1State extends State<HiveApp1> {

  @override
  void dispose() {
    Hive.box('contacts').compact();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Tutorial',
      home: FutureBuilder(
        future: Hive.openBox(
          'contacts',
          compactionStrategy: (int total, int deleted) {
            return deleted > 20;
          },
        ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return ContactPage();
          } else
            return Scaffold();
        },
      ),
    );
  }
}
