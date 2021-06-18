import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final initialScripts = [
  '''
  create table _todo_list (
    id integer primary key autoincrement,
    alias text not null
  )
  ''',
  '''
  create table _task (
    id integer primary key autoincrement,
    description text,
    todo_list_id integer not null,
    CONSTRAINT fk_todo_lists
      FOREIGN KEY (todo_list_id)
      REFERENCES _todo_list(id)
  );
  '''
];

final migrationScripts = [
  '''
  alter table _task add column done integer default 0;
  '''
];

class MyDatabase {
  static Database? db;

  static const DB_NAME = 'OnlineShop';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>>? selectQueryResult, int? insertAndUpdateQueryResult, List<dynamic>? params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      //await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath(DB_NAME);
    db = await openDatabase(path,
      version: migrationScripts.length + 1,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    // assert(initialScripts != null, '初始化資料庫指令不得為空');
    // assert(migrationScripts != null, '整合資料庫指令不得為空');

    initialScripts.forEach((script) async {
      await db.execute(script);
    });
    migrationScripts.forEach((script) async {
      await db.execute(script);
    });
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    assert(oldVersion < newVersion, '新版本($newVersion)必須大於舊版本($oldVersion)');
    assert(migrationScripts.length >= newVersion, '新版本($newVersion)必須擁有${newVersion - migrationScripts.length}個整合資料庫指令');

    for (var i = oldVersion - 1; i <= newVersion - 1; i++) {
      await db.execute(migrationScripts[i]);
    }
  }
}