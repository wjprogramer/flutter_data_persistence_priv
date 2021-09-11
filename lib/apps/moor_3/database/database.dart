import 'dart:io';

import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:moor/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app3.db'));

    if (!await file.exists()) {
      // Extract the pre-populated datbaase file from assets
      final blob = await rootBundle.load('assets/databases/chinook.db');
      final buffer = blob.buffer;
      final bytes = buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);
      await file.writeAsBytes(bytes);
    }

    return VmDatabase(file);
  });
}

@UseMoor(tables: [])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
