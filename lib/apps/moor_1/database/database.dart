import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

// assuming that your file is called filename.dart. This will give an error at first,
// but it's needed for moor to know about the generated code
part 'database.g.dart';

// this will generate a table called "todos" for us. The rows of that table will
// be represented by a class called "Todo".
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
}

// This will make moor generate a class called "Category" to represent a row in this table.
// By default, "Categorie" would have been used because it only strips away the trailing "s"
// in the table name.
@DataClassName("Category")
class Categories extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
}

// this annotation tells moor to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@UseMoor(tables: [Todos, Categories])
class MyDatabase extends _$MyDatabase {
  MyDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // loads all todo entries
  Future<List<Todo>> get allTodoEntries => select(todos).get();

  // watches all todo entries in a given category. The stream will automatically
  // emit new items whenever the underlying data changes.
  Stream<List<Todo>> watchEntriesInCategory(Category c) {
    return (select(todos)..where((t) => t.category.equals(c.id))).watch();
  }
}