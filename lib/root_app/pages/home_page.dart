import 'package:flutter/material.dart';
import 'package:flutter_data_persistence_priv/apps/hive_1/main.dart';
import 'package:flutter_data_persistence_priv/shared/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Persistence'),
      ),
      body: MyListView(
        children: [
          MyButton(
            text: 'Hive _ 1',
            myButtonTypes: [
              MyButtonType.runApp,
            ],
            onPressed: runHiveApp1,
          )
        ],
      ),
    );
  }
}
