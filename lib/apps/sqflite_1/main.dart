import 'package:flutter/material.dart';

import 'my_database.dart';

/// 參考 https://github.com/flutterings/sqflite_migration
/// 文章 https://efthymis.com/migrating-a-mobile-database-in-flutter-sqlite/
///
/// 已將功能都整合進 repository/my_database，不須再參考來源
void runSqlMigrationApp() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<String> initDatabase() async {
    await MyDatabase().initDatabase();
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
