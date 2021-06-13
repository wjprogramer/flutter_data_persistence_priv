import 'package:flutter/cupertino.dart';
import 'package:flutter_data_persistence_priv/apps/hive_1/hive_app_1.dart';
import 'package:flutter_data_persistence_priv/apps/hive_1/models/contact.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

void runHiveApp1() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  /// Hive init
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(ContactAdapter());

  runApp(HiveApp1());
}